<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="i18n mods xlink mcrxsl xalan exslt"
>

  <xsl:import  href="xslImport:modsmeta:metadata/mir-abstract.xsl" />
  <xsl:include href="resource:xsl/mir-utils.xsl" />
  <xsl:param name="MIR.Layout.Abstract.Type.Classification"/>
  <xsl:variable name="objectID" select="/mycoreobject/@ID" />
  <xsl:variable name="modsPart" select="concat('mods.part.', $objectID)" />
  <xsl:variable name="nbsp" select="'&#xa0;'"/>

  <xsl:template match="/">

    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

    <!-- badges -->
    <div id="mir-abstract-badges">
      <xsl:variable name="dateIssued">
        <xsl:choose>
          <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
            <xsl:choose>
              <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and @point]">
                <xsl:apply-templates mode="mods.datePublished" select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and @point='start']" />
                <xsl:text>|</xsl:text>
                <xsl:apply-templates mode="mods.datePublished" select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and @point='end']" />
              </xsl:when>
              <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and not(@point)]">
                <xsl:apply-templates mode="mods.datePublished" select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$mods/mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"><xsl:apply-templates mode="mods.datePublished" select="$mods/mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="firstDate">
        <xsl:for-each select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
          <xsl:sort data-type="number" select="count(ancestor::mods:originInfo[not(@eventType) or @eventType='publication'])" />
          <xsl:if test="position()=1">
            <xsl:value-of select="." />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

        <!-- TODO: Update badges -->
      <div id="badges">
        <xsl:for-each select="$mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern']">
          <xsl:call-template name="categorySearchLink">
            <xsl:with-param name="class" select="'mods_genre badge badge-info'" />
            <xsl:with-param name="node" select="." />
            <xsl:with-param name="owner"  select="$owner" />
          </xsl:call-template>
        </xsl:for-each>

        <xsl:if test="string-length($dateIssued) > 0">
          <time datetime="{$dateIssued}" data-toggle="tooltip" title="Publication date">
              <xsl:variable name="dateText">
                <xsl:variable name="date">
                  <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
                    <xsl:with-param name="string" select="$dateIssued" />
                    <xsl:with-param name="delimiter" select="'|'" />
                  </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="exslt:node-set($date)/token">
                  <xsl:if test="position()=2">
                    <xsl:text> - </xsl:text>
                  </xsl:if>
                  <xsl:if test="mcrxsl:trim(.) != ''">
                    <xsl:variable name="format">
                      <xsl:choose>
                        <xsl:when test="string-length(normalize-space(.))=4">
                          <xsl:value-of select="i18n:translate('metaData.dateYear')" />
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space(.))=7">
                          <xsl:value-of select="i18n:translate('metaData.dateYearMonth')" />
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space(.))=10">
                          <xsl:value-of select="i18n:translate('metaData.dateYearMonthDay')" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="i18n:translate('metaData.dateTime')" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:call-template name="formatISODate">
                      <xsl:with-param name="date" select="." />
                      <xsl:with-param name="format" select="$format" />
                    </xsl:call-template>
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
            <xsl:choose>
              <xsl:when test="$firstDate and $firstDate != ''">
                <xsl:call-template name="searchLink">
                  <xsl:with-param name="class" select="'date_published badge badge-primary'" />
                  <xsl:with-param name="linkText" select="$dateText" />
                  <xsl:with-param name="query" select="concat('*&amp;fq=mods.dateIssued:',$firstDate, '&amp;owner=createdby:', $owner)" />
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <span class="date_published badge badge-primary">
                  <xsl:value-of select="$dateText"/>
                </span>
              </xsl:otherwise>
            </xsl:choose>
          </time>
        </xsl:if>

        <xsl:variable name="accessCondition" select="substring-after(normalize-space($mods/mods:accessCondition[@type='use and reproduction']/@xlink:href),'#')" />
        <xsl:if test="$accessCondition">
          <xsl:variable name="linkText">
            <xsl:choose>
              <xsl:when test="contains($accessCondition, 'rights_reserved')">
                <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.rightsReserved')" />
              </xsl:when>
              <xsl:when test="contains($accessCondition, 'oa_nlz')">
                <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.oa_nlz.short')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="mcrxsl:getDisplayName('mir_licenses',$accessCondition)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="searchLink">
            <xsl:with-param name="class" select="'access_condition badge badge-success'" />
            <xsl:with-param name="linkText" select="$linkText" />
            <xsl:with-param name="query" select="concat('*&amp;fq=link:*',$accessCondition, '&amp;owner=createdby:', $owner)" />
          </xsl:call-template>
        </xsl:if>
        <xsl:variable name="doc-state" select="/mycoreobject/service/servstates/servstate/@categid" />
        <xsl:if test="$doc-state">
          <div class="doc_state">
            <xsl:variable name="status-i18n">
              <!-- template in mir-utils.xsl -->
              <xsl:call-template name="get-doc-state-label">
                <xsl:with-param name="state-categ-id" select="$doc-state"/>
              </xsl:call-template>
            </xsl:variable>
            <span class="badge mir-{$doc-state}" title="{i18n:translate('component.mods.metaData.dictionary.status')}">
              <xsl:value-of select="$status-i18n" />
            </span>
          </div>
        </xsl:if>
      </div><!-- end: badges -->
    </div><!-- end: badgets structure -->

    <!-- headline -->
    <div id="mir-abstract-title">
      <h1>
        <xsl:apply-templates mode="mods.title" select="$mods">
          <xsl:with-param name="asHTML" select="true()" />
          <xsl:with-param name="withSubtitle" select="true()" />
        </xsl:apply-templates>
      </h1>
    </div>

    <!-- authors, description, children -->
    <div id="mir-abstract-plus">

      <xsl:if test="$mods/mods:name[mods:role/mods:roleTerm/text()='aut'] or $mods/mods:name[mods:role/mods:roleTerm/text()='edt']">
        <div id="authors_short">
          <xsl:choose>
            <xsl:when test="$mods/mods:name[mods:role/mods:roleTerm/text()='aut']">
              <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm/text()='aut']">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="'; '" />
                </xsl:if>
                <xsl:apply-templates select="." mode="mirNameLink" />
                <xsl:if test="mods:etal">
                  <em>et.al.</em>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$mods/mods:name[mods:role/mods:roleTerm/text()='edt']">
              <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm/text()='edt']">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="'; '" />
                </xsl:if>
                <xsl:apply-templates select="." mode="mirNameLink" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="i18n:translate('mir.abstract.editor')" />
                <xsl:if test="mods:etal">
                  <em>et.al.</em>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </div>
      </xsl:if>

      <xsl:if test="$mods/mods:abstract">
        <xsl:variable name="aFilter">
          <xsl:for-each select="$mods/mods:abstract">
            <xsl:choose>
              <xsl:when test="(string-length(@altRepGroup) &gt; 0) and (string-length(@altFormat) &gt; 0)">
                <xsl:copy-of select="document(concat('unescape-html-content:', @altFormat))"/>
              </xsl:when>
              <xsl:when test="@altRepGroup and count(../mods:abstract[@altRepGroup=current()/@altRepGroup]) = 1">
                <xsl:copy-of select="."/>
              </xsl:when>
              <xsl:when test="not(@altRepGroup)">
                <xsl:copy-of select="."/>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="abstracts" select="xalan:nodeset($aFilter)" />

        <xsl:choose>
          <xsl:when test="count($abstracts/mods:abstract) &gt; 1">
            <xsl:variable name="fnode" select="$abstracts/mods:abstract[@xml:lang=$CurrentLang][1]"/>

            <xsl:variable name="first-abstract-in-current-lang-position">
              <xsl:for-each select="$abstracts/mods:abstract">
                <xsl:if test=".= $fnode">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>

            <div id="mir-abstract-tabs">
              <ul class="nav nav-tabs justify-content-end" role="tablist">
                <xsl:for-each select="$abstracts/mods:abstract">
                  <xsl:variable name="tabName">
                    <xsl:choose>
                      <xsl:when test="@type and $MIR.Layout.Abstract.Type.Classification">
                        <xsl:value-of select="document(concat('classification:metadata:0:children:', $MIR.Layout.Abstract.Type.Classification,':',@type))//category/label[@xml:lang=$CurrentLang]/@text"/>
                      </xsl:when>
                      <xsl:when test="@xml:lang">
                        <xsl:value-of
                          select="document(concat('classification:metadata:0:children:rfc5646:',./@xml:lang))//category/label[@xml:lang=$CurrentLang]/@text" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of
                          select="document(concat('classification:metadata:0:children:rfc5646:',$mods/mods:language/mods:languageTerm[@authority='rfc5646'][@type='code']))//category/label[@xml:lang=$CurrentLang]/@text" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <li class="nav-item">
                    <a class="nav-link" href="#tab{position()}" role="tab" data-toggle="tab">
                      <xsl:choose>
                        <xsl:when test="$first-abstract-in-current-lang-position = position()">
                          <xsl:attribute name="class">active nav-link</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:if test="position() = 1 and not($first-abstract-in-current-lang-position)">
                            <xsl:attribute name="class">active nav-link</xsl:attribute>
                          </xsl:if>
                        </xsl:otherwise>
                      </xsl:choose>

                      <xsl:value-of select="$tabName" />
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
              <div class="tab-content">
                <xsl:for-each select="$abstracts/mods:abstract">
                  <div class="tab-pane ellipsis ellipsis-text" role="tabpanel" id="tab{position()}">
                    <xsl:if test="@xml:lang">
                      <xsl:attribute name="lang">
                        <xsl:value-of select="@xml:lang" />
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                      <xsl:when test="$first-abstract-in-current-lang-position = position()">
                          <xsl:attribute name="class">tab-pane ellipsis ellipsis-text active</xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:if test="position() = 1 and not($first-abstract-in-current-lang-position)">
                          <xsl:attribute name="class">tab-pane ellipsis ellipsis-text active</xsl:attribute>
                        </xsl:if>
                      </xsl:otherwise>
                    </xsl:choose>
                    <p>
                      <span class="ellipsis-description">
                        <xsl:copy-of select="node()"/>
                      </span>
                    </p>
                  </div>
                </xsl:for-each>
                <div id="mir-abstract-overlay">
                  <a href="#" class="readless d-none" title="read less">
                    <xsl:value-of select="i18n:translate('mir.abstract.readless')" />
                  </a>
                  <div class="mir-abstract-overlay-tran readmore d-none"></div>
                  <a href="#" class="readmore d-none" title="read more">
                    <xsl:value-of select="i18n:translate('mir.abstract.readmore')" />
                  </a>
                </div>
              </div>
            </div>

          </xsl:when>
          <xsl:otherwise>
            <div id="mir-abstract">
              <div class="ellipsis ellipsis-text">
                <xsl:if test="@xml:lang">
                  <xsl:attribute name="lang">
                    <xsl:value-of select="@xml:lang" />
                  </xsl:attribute>
                </xsl:if>
                <p>
                  <span class="ellipsis-description">
                    <xsl:copy-of select="$abstracts/mods:abstract/node()"/>
                  </span>
                </p>
              </div>
              <div id="mir-abstract-overlay">
                <a href="#" class="readless d-none" title="read less">
                  <xsl:value-of select="i18n:translate('mir.abstract.readless')" />
                </a>
                <div class="mir-abstract-overlay-tran readmore d-none"></div>
                <a href="#" class="readmore d-none" title="read more">
                  <xsl:value-of select="i18n:translate('mir.abstract.readmore')" />
                </a>
              </div>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <!-- check for relatedItem containing mycoreobject ID dependent on current user using solr query on field mods.relatedItem -->
      <xsl:variable name="state">
        <xsl:choose>
          <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
            state:*
          </xsl:when>
          <xsl:otherwise>
            state:published OR createdby:
            <xsl:value-of select="$CurrentUser" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.references:', $objectID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.isReferencedBy')"/>
      </xsl:call-template>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.preceding:', $objectID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.succeeding')"/>
      </xsl:call-template>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.original:', $objectID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.otherVersion')"/>
      </xsl:call-template>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.reviewOf:', $objectID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.review')"/>
      </xsl:call-template>

    </div><!-- end: authors, description, children -->

    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="findRelatedItems">
    <xsl:param name="query"/>
    <xsl:param name="label"/>

    <xsl:variable name="hitsSortList" xmlns:encoder="xalan://java.net.URLEncoder"
                  select="document(concat('solr:q=',encoder:encode($query), '&amp;rows=1000&amp;sort=mods.part.order.', $objectID, '%20desc,mods.dateIssued%20desc,%20mods.dateIssued.host%20desc,',  $modsPart, '%20desc,%20mods.title.main%20desc&amp;group=true&amp;group.limit=1000&amp;group.field=mods.yearIssued'))/response/lst[@name='grouped']/lst[@name='mods.yearIssued']" />
    <xsl:if test="$hitsSortList/int[@name='matches'] &gt; 0">
        <xsl:call-template name="listRelatedItems">
          <xsl:with-param name="hits" select="$hitsSortList"/>
          <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="listRelatedItems">
    <xsl:param name="hits"/>
    <xsl:param name="label"/>
    <h3>
      <xsl:value-of select="$label" />
      <xsl:if
              test="$hits/arr[@name='groups']/lst/result/@numFound &gt; 0 and not($hits/arr[@name='groups']/lst/null/@name='groupValue') and count($hits/arr[@name='groups']/lst) &gt; 1"
      >
        <a id="mir_relatedItem_showAll" class="float-right" href="#"><xsl:value-of select="i18n:translate('mir.abstract.showGroups')" /></a>
        <a id="mir_relatedItem_hideAll" class="float-right" href="#"><xsl:value-of select="i18n:translate('mir.abstract.hideGroups')" /></a>
      </xsl:if>
    </h3>
    <xsl:choose>
      <xsl:when
              test="$hits/arr[@name='groups']/lst/result/@numFound &gt; 0 and not($hits/arr[@name='groups']/lst/null/@name='groupValue') and count($hits/arr[@name='groups']/lst) &gt; 1"
      >
        <ul id="mir_relatedItem">
          <xsl:for-each select="$hits/arr[@name='groups']/lst">
            <li>
              <span class="fas fa-chevron-right"></span>
              <span>
                <xsl:value-of select="int[@name='groupValue']" />
              </span>
              <ul>
                <xsl:for-each select="result/doc">
                  <li>
                    <xsl:call-template name="printRelatedItem">
                      <xsl:with-param  name="responseFieldModsPart" select="str[contains(@name,'mods.part.')][contains(@name,$objectID)]" />
                      <xsl:with-param  name="title"                 select="str[@name='mods.title.main']" />
                      <xsl:with-param  name="linkText"              select="str[@name='search_result_link_text']" />
                    </xsl:call-template>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:for-each select="$hits/arr[@name='groups']/lst/result/doc">
            <li>
              <xsl:call-template name="printRelatedItem">
                <xsl:with-param  name="responseFieldModsPart" select="str[contains(@name,'mods.part.')][contains(@name,$objectID)]" />
                <xsl:with-param  name="title"                 select="str[@name='mods.title.main']" />
                <xsl:with-param  name="linkText"              select="str[@name='search_result_link_text']" />
              </xsl:call-template>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="printRelatedItem">
    <xsl:param name="responseFieldModsPart" />
    <xsl:param name="title" />
    <xsl:param name="linkText" />
    <a href="{$WebApplicationBaseURL}receive/{str[@name='returnId']}">
      <xsl:if test="string-length($responseFieldModsPart) &gt; 0">
        <xsl:value-of select="$responseFieldModsPart" />
      </xsl:if>
      <xsl:if test="string-length($responseFieldModsPart) &gt; 0 and not($title = $responseFieldModsPart)">
        <xsl:text> - </xsl:text>
        <xsl:value-of select="$linkText" />
      </xsl:if>
      <xsl:if test="string-length($responseFieldModsPart) = 0">
        <xsl:value-of select="$linkText" />
      </xsl:if>
    </a>
  </xsl:template>

  <xsl:template mode="mods.printTitle" match="mods:titleInfo" priority="1">
    <xsl:param name="asHTML" select="false()" />
    <xsl:param name="withSubtitle" select="false()" />

    <xsl:variable name="altRepGroup" select="@altRepGroup" />
    <xsl:variable name="hasAlternateFormat" select="count(..//mods:titleInfo[(@altRepGroup = $altRepGroup) and (string-length(@altFormat) &gt; 0)]) &gt; 0" />

    <xsl:choose>
      <xsl:when test="$asHTML and $hasAlternateFormat and (string-length(@altFormat) = 0)">
        <!-- ignore titleInfo -->
      </xsl:when>
      <xsl:when test="$asHTML and $hasAlternateFormat and (string-length(@altFormat) &gt; 0)">
        <xsl:variable name="alternateContent"
                      select="document(concat('unescape-html-content:',..//mods:titleInfo[(@altRepGroup = $altRepGroup) and (string-length(@altFormat) &gt; 0)]/@altFormat))/*[local-name()='titleInfo']" />

        <xsl:if test="$alternateContent/nonSort">
          <xsl:copy-of select="$alternateContent/nonSort/node()" />

        </xsl:if>
        <xsl:copy-of select="$alternateContent/title/node()" />
        <xsl:if test="$withSubtitle and $alternateContent/subTitle">
          <span class="subtitle">
            <span class="delimiter">
              <xsl:value-of select="$nbsp" />
              <xsl:text>: </xsl:text>
            </span>
            <xsl:copy-of select="$alternateContent/subTitle/node()" />
          </span>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="mods:nonSort">
          <xsl:value-of select="concat(mods:nonSort, ' ')" />
        </xsl:if>
        <xsl:value-of select="mods:title" />
        <xsl:if test="$withSubtitle and mods:subTitle">
          <span class="subtitle">
            <span class="delimiter">
              <xsl:value-of select="$nbsp" />
              <xsl:text>: </xsl:text>
            </span>
            <xsl:value-of select="mods:subTitle" />
          </span>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
