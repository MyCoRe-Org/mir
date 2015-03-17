<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions" xmlns:cmd="http://www.cdlib.org/inside/diglib/copyrightMD"
  exclude-result-prefixes="i18n mcr mods xlink mcrurn cmd">
  <xsl:import href="xslImport:modsmeta:metadata/mir-citation.xsl" />
  <xsl:include href="mods-highwire.xsl" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" select="''" />
  <xsl:param name="MCR.DOI.Prefix" select="'10.5072'" />
  <xsl:template match="/">

    <!-- ==================== Highwire Press tags ==================== -->
    <citation_meta>
      <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" mode="highwire" />
    </citation_meta>

    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <div id="mir-citation">
      <div class="shariff" data-theme="white"></div><!-- for more params see http://heiseonline.github.io/shariff/ -->
      <xsl:if test="//mods:mods/mods:identifier[@type='doi']">
        <script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script>
        <div data-badge-popover="right" data-badge-type="2" data-doi="{//mods:identifier[@type='doi']}" data-hide-no-mentions="true" class="altmetric-embed"></div>
      </xsl:if>

      <p>
        <xsl:apply-templates select="$mods" mode="authorList" />
        <xsl:apply-templates select="$mods" mode="year" />
        <xsl:apply-templates mode="mods.title" select="$mods" />
        <xsl:value-of select="'.'" />
      </p>
      <!--
      <p>
        <small>
          Further citation formats:
          <a href="http://crosscite.org/citeproc/">DOI Citation Formatter</a>
          .
        </small>
      </p>
       -->
      <!-- cite url - TODO: Should be URN if one is given -->
      <p id="cite_link_box">

        <xsl:variable name="derivateURN">
          <xsl:for-each select="mycoreobject/structure/derobjects/derobject">
            <xsl:variable name="derId" select="@xlink:href" />
            <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />
            <xsl:variable name="derivateWithURN" select="mcrurn:hasURNDefined($derId)" />
            <xsl:if test="$derivateWithURN=true()">
              <xsl:value-of select="$derivateXML/mycorederivate/derivate/fileset/@urn" />
              <xsl:text>|</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="//mods:mods/mods:identifier[@type='doi'] and contains(//mods:mods/mods:identifier[@type='doi'], $MCR.DOI.Prefix)">
            <xsl:variable name="doi" select="//mods:mods/mods:identifier[@type='doi']" />
            <a id="copy_cite_link"
               href="http://dx.doi.org/{$doi}"
               class="label label-info">
               <xsl:text>DOI:</xsl:text>
               <xsl:value-of select="$doi" />
            </a>
            <textarea id="cite_link_code_box" class="code">
              <xsl:value-of select="$doi" />
            </textarea>
          </xsl:when>
          <xsl:when test="string-length($derivateURN) &gt; 0">
            <xsl:variable name="urn" select="substring-before($derivateURN,'|')" /><!-- get first URN only -->
            <a id="url_site_link" href="{$MCR.URN.Resolver.MasterURL}{$urn}">
              <xsl:value-of select="$urn" />
            </a>
            <br />
            <a id="copy_cite_link" class="label label-info" href="{$MCR.URN.Resolver.MasterURL}{$urn}">
              <xsl:text>Zitier-Link</xsl:text>
            </a>
            <textarea id="cite_link_code_box" class="code">
              <xsl:value-of select="concat($MCR.URN.Resolver.MasterURL, $urn)" />
            </textarea>
          </xsl:when>
          <xsl:otherwise>
            <a id="copy_cite_link"
               href="{$WebApplicationBaseURL}receive/{mycoreobject/@ID}"
               class="label label-info">
               <xsl:text>Zitier-Link</xsl:text>
            </a>
            <textarea id="cite_link_code_box" class="code">
              <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',mycoreobject/@ID)" />
            </textarea>
          </xsl:otherwise>
        </xsl:choose>
      </p>
      <script>
        $('#copy_cite_link').click(function(){
          $('#cite_link_code_box').toggle();
          $("#cite_link_code_box").focus();
          return false;
        });
        $("#cite_link_code_box").focus(function() {
            var $this = $(this);
            $this.select();

            // Work around Chrome's little problem
            $this.mouseup(function() {
                // Prevent further mouseup intervention
                $this.unbind("mouseup");
                return false;
            });
        });
      </script>
    </div>

  <xsl:if test="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition">
    <div id="mir-access-rights">
      <xsl:if test="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='copyrightMD']">
        <p>
          <strong><xsl:value-of select="i18n:translate('mir.rightsHolder')" /></strong>
          <xsl:text> </xsl:text>
          <xsl:value-of select="//mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name" />
        </p>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition/@type='use and reproduction'">
          <p>
            <strong><xsl:value-of select="i18n:translate('mir.useAndReproduction')" /></strong>
            <br />
            <xsl:variable name="trimmed" select="normalize-space(.)" />
            <xsl:choose>
              <xsl:when test="contains($trimmed, 'cc_by')">
                <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']" mode="cc-logo" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'rights_reserved')">
                <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']" mode="rights_reserved" />
              </xsl:when>
              <xsl:when test="contains($trimmed, 'oa_nlz')">
                <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']" mode="oa_nlz" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']" />
              </xsl:otherwise>
            </xsl:choose>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <p>
            <strong><xsl:value-of select="i18n:translate('mir.useAndReproduction')" /></strong>
            <xsl:text> </xsl:text>
            <xsl:value-of select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']" />
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:if>

    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="mods:mods" mode="authorList">
    <xsl:choose>
      <xsl:when test="mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:choose>
            <xsl:when test="position()=1">
              <strong>
                <xsl:value-of select="mods:displayForm" />
              </strong>
            </xsl:when>
            <xsl:when test="position()=2">
              <xsl:text>&#160;</xsl:text><!-- add whitespace -->
              <em>et al</em>
            </xsl:when>
            <xsl:otherwise>
              <!-- other authors -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'N.N.'" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#160;</xsl:text><!-- add whitespace -->
  </xsl:template>

  <xsl:template match="mods:mods" mode="year">
    <xsl:variable name="dateIssued">
      <xsl:apply-templates mode="mods.datePublished" select="." />
    </xsl:variable>
    <xsl:if test="string-length($dateIssued) &gt; 0">
      <xsl:value-of select="'('" />
      <xsl:call-template name="formatISODate">
        <xsl:with-param name="date" select="$dateIssued" />
        <xsl:with-param name="format" select="i18n:translate('metaData.dateYear')" />
      </xsl:call-template>
      <xsl:value-of select="'). '" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>