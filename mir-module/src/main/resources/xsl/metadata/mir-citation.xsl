<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"
  xmlns:cmd="http://www.cdlib.org/inside/diglib/copyrightMD" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="i18n mcr mods xlink mcrurn cmd exslt"
>
  <xsl:import href="xslImport:modsmeta:metadata/mir-citation.xsl" />
  <xsl:include href="mods-highwire.xsl" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" select="''" />
  <xsl:param name="MCR.DOI.Prefix" select="''" />
  <xsl:param name="MCR.URN.SubNamespace.Default.Prefix" select="''" />
  <xsl:param name="MIR.citationStyles" select="''" />
  <xsl:param name="MIR.altmetrics" select="'show'" />
  <xsl:param name="MIR.altmetrics.hide" select="'true'" />
  <xsl:param name="MIR.shariff" select="'show'" />
  <xsl:template match="/">

    <!-- ==================== Highwire Press tags ==================== -->
    <citation_meta>
      <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" mode="highwire" />
    </citation_meta>

    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <div id="mir-citation">
      <xsl:if test="$MIR.altmetrics = 'show'">
        <script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script>
        <xsl:choose>
          <xsl:when test="//mods:mods/mods:identifier[@type='doi']">
            <div data-badge-details="right" data-badge-type="donut" data-doi="{//mods:mods/mods:identifier[@type='doi']}" data-hide-no-mentions="{$MIR.altmetrics.hide}"
              class="altmetric-embed"
            ></div>
          </xsl:when>
          <xsl:when test="//mods:mods/mods:identifier[@type='uri']">
            <div data-badge-details="right" data-badge-type="donut" data-uri="{//mods:mods/mods:identifier[@type='uri']}" data-hide-no-mentions="{$MIR.altmetrics.hide}"
              class="altmetric-embed"
            ></div>
          </xsl:when>
          <xsl:otherwise>
            <div data-badge-details="right" data-badge-type="donut" data-uri="{$WebApplicationBaseURL}receive/{mycoreobject/@ID}" data-hide-no-mentions="{$MIR.altmetrics.hide}"
              class="altmetric-embed"
            ></div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$MIR.shariff = 'show'">
        <div class="shariff" data-theme="white"></div><!-- for more params see http://heiseonline.github.io/shariff/ -->
      </xsl:if>

      <div id="citation-style">
        <span>
          <strong>
            <xsl:value-of select="i18n:translate('mir.citationStyle')" />
          </strong>
        </span>
        <xsl:if test="//mods:mods/mods:identifier[@type='doi'] and string-length($MIR.citationStyles) &gt; 0">
          <xsl:variable name="cite-styles">
            <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
              <xsl:with-param name="string" select="$MIR.citationStyles" />
              <xsl:with-param name="delimiter" select="','" />
            </xsl:call-template>
          </xsl:variable>
          <select class="form-control input-sm" id="crossref-cite">
            <option>deutsche-sprache</option>
            <xsl:for-each select="exslt:node-set($cite-styles)/token">
              <option>
                <xsl:value-of select="." />
              </option>
            </xsl:for-each>
          </select>
        </xsl:if>
        <p id="citation-text">
          <xsl:apply-templates select="$mods" mode="authorList" />
          <xsl:apply-templates select="$mods" mode="title" />
          <xsl:apply-templates select="$mods" mode="originInfo" />
          <xsl:apply-templates select="$mods" mode="issn" />
        </p>
      </div>

      <p id="cite_link_box">
        <xsl:variable name="derivateURN">
          <xsl:apply-templates select="mycoreobject/structure/derobjects/derobject" mode="urn" />
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="//mods:mods/mods:identifier[@type='doi'] and contains(//mods:mods/mods:identifier[@type='doi'], $MCR.DOI.Prefix)">
            <xsl:variable name="doi" select="//mods:mods/mods:identifier[@type='doi']" />
            <a id="url_site_link" href="https://dx.doi.org/{$doi}">
              <xsl:value-of select="$doi" />
            </a>
            <br />
            <a id="copy_cite_link" class="label label-info" href="#">
              <xsl:value-of select="i18n:translate('mir.citationLink')" />
            </a>
          </xsl:when>
          <xsl:when test="string-length($derivateURN) &gt; 0">
            <xsl:variable name="urn" select="substring-before($derivateURN,'|')" /><!-- get first URN only -->
            <a id="url_site_link" href="{$MCR.URN.Resolver.MasterURL}{$urn}">
              <xsl:value-of select="$urn" />
            </a>
            <br />
            <a id="copy_cite_link" class="label label-info" href="#">
              <xsl:value-of select="i18n:translate('mir.citationLink')" />
            </a>
          </xsl:when>
          <xsl:when test="//mods:mods/mods:identifier[@type='urn'] and contains(//mods:mods/mods:identifier[@type='urn'], $MCR.URN.SubNamespace.Default.Prefix)">
            <xsl:variable name="urn" select="//mods:mods/mods:identifier[@type='urn']" />
            <a id="url_site_link" href="{$MCR.URN.Resolver.MasterURL}{$urn}">
              <xsl:value-of select="$urn" />
            </a>
            <br />
            <a id="copy_cite_link" class="label label-info" href="#">
              <xsl:value-of select="i18n:translate('mir.citationLink')" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a id="copy_cite_link" href="#" class="label label-info">
              <xsl:value-of select="i18n:translate('mir.citationLink')" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </p>
      <xsl:apply-templates select="//mods:mods" mode="identifierListModal" />
      <xsl:if test="//mods:mods/mods:identifier[@type='doi']">
        <script>
          $.ajax({
            type: 'GET',
            url: 'https://data.datacite.org/text/x-bibliography/<xsl:value-of select="//mods:mods/mods:identifier[@type='doi']" />',
            // fixed MIR-550: overrides wrong charset=iso-8859-1
            beforeSend: function(jqXHR) {
              jqXHR.overrideMimeType('text/html;charset=UTF-8');
            },
            headers: {
              'Accept': 'text/x-bibliography; style=deutsche-sprache; locale=de-DE'
            },
            success: function(data){
              $('#citation-text').text(data);
            }
          });

          $('#crossref-cite').on('change', function() {
            $.ajax({
              type: 'GET',
              url: 'https://data.datacite.org/text/x-bibliography/<xsl:value-of select="//mods:mods/mods:identifier[@type='doi']" />',
              // fixed MIR-550: overrides wrong charset=iso-8859-1
              beforeSend: function(jqXHR) {
                jqXHR.overrideMimeType('text/html;charset=UTF-8');
              },
              headers: {
                'Accept': 'text/x-bibliography; style=' + $(this).val() + '; locale=de-DE'
              },
              success: function(data){
                $('#citation-text').text(data);
              }
            });
          });
        </script>
      </xsl:if>
    </div>

    <xsl:if test="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[contains('copyrightMD|use and reproduction', @type)]">
      <div id="mir-access-rights">
        <xsl:if test="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='copyrightMD']">
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('mir.rightsHolder')" />
            </strong>
            <xsl:text> </xsl:text>
            <xsl:value-of select="//mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name" />
          </p>
        </xsl:if>
        <xsl:if test="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']">
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('mir.useAndReproduction')" />
            </strong>
            <br />
            <xsl:variable name="trimmed"
              select="substring-after(normalize-space(mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']/@xlink:href),'#')" />
            <xsl:choose>
              <xsl:when test="contains($trimmed, 'cc_')">
                <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']"
                  mode="cc-logo" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'rights_reserved')">
                <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']"
                  mode="rights_reserved" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'oa_nlz')">
                <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']"
                  mode="oa_nlz" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'oa')">
                <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']"
                  mode="oa-logo" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']" />
              </xsl:otherwise>
            </xsl:choose>
          </p>
        </xsl:if>
      </div>
    </xsl:if>

    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="mods:mods" mode="authorList">
    <xsl:choose>
      <xsl:when test="mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:choose>
            <xsl:when test="position() &lt; 4">
              <xsl:choose>
                <xsl:when test="mods:namePart[@type='family'] and mods:namePart[@type='given']">
                  <xsl:value-of select="mods:namePart[@type='family']" />
                  <tex>, </tex>
                  <xsl:value-of select="mods:namePart[@type='given']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mods:displayForm" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="position() = 4 and not(mods:etal)">
              <em>et al</em>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="not(position()=last()) and position() &lt; 4 and not(mods:etal)">
            <xsl:text> / </xsl:text>
          </xsl:if>
          <xsl:if test="mods:etal">
            <em>et al</em>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>: </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:mods" mode="identifierListModal">
    <div class="modal fade" id="identifierModal" tabindex="-1" role="dialog" aria-labelledby="modal frame" aria-hidden="true">
      <div class="modal-dialog" style="width: 930px">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close modalFrame-cancel" data-dismiss="modal" aria-label="Close">
              <i class="fa fa-times" aria-hidden="true"></i>
            </button>
            <h4 class="modal-title" id="modalFrame-title">
              <xsl:value-of select="i18n:translate('mir.citationLink')" />
            </h4>
          </div>
          <div id="modalFrame-body" class="modal-body" style="max-height: 560px; overflow: auto">
            <xsl:apply-templates select="mods:identifier[@type='urn' or @type='doi']" mode="identifierList" />
            <xsl:apply-templates select="//structure/derobjects/derobject" mode="urnList" />
            <xsl:if test="not(mods:identifier[@type='urn' or @type='doi']) and (count(exslt:node-set($derURNs)/urn) = 0)">
              <xsl:call-template name="identifierEntry">
                <xsl:with-param name="title" select="'Document-Link'" />
                <xsl:with-param name="id" select="concat($WebApplicationBaseURL, 'receive/', //mycoreobject/@ID)" />
              </xsl:call-template>
            </xsl:if>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='urn' or @type='doi']" mode="identifierList">
    <xsl:variable name="identifier">
      <xsl:if test="contains(@type,'urn')">
        <xsl:text>URN</xsl:text>
      </xsl:if>
      <xsl:if test="contains(@type,'doi')">
        <xsl:text>DOI</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="url">
      <xsl:if test="contains(@type,'urn')">
        <xsl:value-of select="$MCR.URN.Resolver.MasterURL" />
      </xsl:if>
      <xsl:if test="contains(@type,'doi')">
        <xsl:text>https://dx.doi.org/</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="identifierEntry">
      <xsl:with-param name="title" select="concat($identifier, ' (', ., ')')" />
      <xsl:with-param name="id" select="concat($url, .)" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:mods" mode="year">
    <xsl:variable name="dateIssued">
      <xsl:apply-templates mode="mods.datePublished" select="." />
    </xsl:variable>
    <xsl:if test="string-length($dateIssued) &gt; 0">
      <xsl:call-template name="formatISODate">
        <xsl:with-param name="date" select="$dateIssued" />
        <xsl:with-param name="format" select="i18n:translate('metaData.dateYear')" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:mods" mode="originInfo">
    <xsl:variable name="place" select="mods:originInfo/mods:place/mods:placeTerm" />
    <xsl:variable name="edition" select="mods:originInfo/mods:edition" />
    <xsl:variable name="year">
      <xsl:apply-templates select="." mode="year" />
    </xsl:variable>
    <xsl:variable name="publisher" select="mods:originInfo/mods:publisher" />
    <xsl:if test="string-length($place) &gt; 0">
      <xsl:value-of select="$place" />
      <xsl:text>&#160;</xsl:text><!-- add whitespace -->
    </xsl:if>
    <xsl:if test="string-length($edition) &gt; 0">
      <sup>
        <xsl:value-of select="$edition" />
      </sup>
      <xsl:text>&#160;</xsl:text><!-- add whitespace -->
    </xsl:if>
    <xsl:if test="string-length($year) &gt; 0">
      <xsl:value-of select="$year" />
    </xsl:if>
    <xsl:if test="string-length($place) &gt; 0 or string-length($edition) &gt; 0 or string-length($year) &gt; 0">
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:if test="string-length($publisher) &gt; 0">
      <xsl:value-of select="$publisher" />
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:mods" mode="issn">
    <xsl:variable name="issn" select="mods:identifier[@type='issn']" />
    <xsl:if test="string-length($issn) &gt; 0">
      <xsl:text>ISSN: </xsl:text>
      <xsl:value-of select="$issn"/>
      <xsl:value-of select="'.'" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:mods" mode="title">
    <xsl:variable name="title">
      <xsl:apply-templates select="." mode="mods.title" />
    </xsl:variable>
    <xsl:variable name="subtitle">
      <xsl:apply-templates select="." mode="mods.subtitle" />
    </xsl:variable>
    <xsl:if test="string-length($title) &gt; 0">
      <xsl:value-of select="$title"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:if test="string-length($subtitle) &gt; 0">
      <xsl:value-of select="$subtitle"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mycoreobject/structure/derobjects/derobject" mode="urn">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="derivateWithURN" select="mcrurn:hasURNDefined($derId)" />
    <xsl:if test="$derivateWithURN=true()">
        <!-- TODO: we should have a xalan extension that returns a URN directly -->
      <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />
      <xsl:value-of select="$derivateXML/mycorederivate/derivate/fileset/@urn" />
      <xsl:text>|</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:variable name="derURNs">
    <xsl:for-each select="mycoreobject/structure/derobjects/derobject">
      <xsl:variable name="urn">
        <xsl:apply-templates select="." mode="urn" />
      </xsl:variable>
      <xsl:if test="string-length($urn) &gt; 0">
        <urn id="{@xlink:href}">
          <xsl:value-of select="$urn" />
        </urn>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="mycoreobject/structure/derobjects/derobject" mode="urnList">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="derivateURNString">
      <xsl:value-of select="exslt:node-set($derURNs)/urn[@id = $derId]" />
    </xsl:variable>
    <xsl:variable name="derivateURNs">
      <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
        <xsl:with-param name="string" select="$derivateURNString" />
        <xsl:with-param name="delimiter" select="'|'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="exslt:node-set($derivateURNs)/token">
      <xsl:if test="string-length(.) &gt; 0">
        <xsl:call-template name="identifierEntry">
          <xsl:with-param name="title" select="concat('Derivate-URN (', ., ')')" />
          <xsl:with-param name="id" select="concat($MCR.URN.Resolver.MasterURL,.)" />
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="identifierEntry">
    <xsl:param name="title" />
    <xsl:param name="id" />
    <xsl:if test="string-length($id) &gt; 0">
      <div class="mir_identifier">
        <p>
          <xsl:value-of select="$title" />
        </p>
        <div class="mir_copy_wrapper">
          <span class="glyphicon glyphicon-copy mir_copy_identifier" data-toggle="tooltip" data-placement="left" aria-hidden="true" title="Copy Identifier"
            data-org-title="Copy Identifier"
          ></span>
        </div>
        <pre>
          <a href="{$id}">
            <xsl:value-of select="$id" />
          </a>
        </pre>
        <input type="text" class="hidden mir_identifier_hidden_input" value="{$id}"></input>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>