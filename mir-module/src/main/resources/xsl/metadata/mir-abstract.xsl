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
  <xsl:include href="resource:xsl/badges/mir-badges-entry-point.xsl" />
  <xsl:param name="MIR.Layout.Abstract.Type.Classification"/>
  <xsl:param name="RequestURL"/>
  <xsl:variable name="objectID" select="/mycoreobject/@ID" />
  <xsl:variable name="modsPart" select="concat('mods.part.', $objectID)" />
  <xsl:variable name="nbsp" select="'&#xa0;'"/>

  <xsl:template match="/">

    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

    <!-- badges -->
    <div id="mir-abstract-badges">
      <div id="badges">
        <xsl:apply-templates select="mycoreobject" mode="mycoreobject-badge"/>
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
            <xsl:variable name="first-abstract-in-current-lang-node" select="$abstracts/mods:abstract[@xml:lang=$CurrentLang][1]"/>
            <xsl:variable name="first-abstract-in-current-lang-position">
              <xsl:for-each select="$abstracts/mods:abstract">
                <xsl:sort select="@type"/>
                <xsl:sort select="@xml:lang"/>

                <xsl:if test=".= $first-abstract-in-current-lang-node">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>

            <div id="mir-abstract-tabs">
              <ul class="nav nav-tabs justify-content-end" role="tablist">
                <xsl:for-each select="$abstracts/mods:abstract">
                  <xsl:sort select="@type"/>
                  <xsl:sort select="@xml:lang"/>

                  <xsl:variable name="tabName">
                    <xsl:choose>
                      <xsl:when test="@type and $MIR.Layout.Abstract.Type.Classification">
                        <xsl:value-of select="mcrxsl:getDisplayName($MIR.Layout.Abstract.Type.Classification, @type)"/>
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
                          <xsl:if test="position() = 1 and not($first-abstract-in-current-lang-position &gt;0)">
                            <xsl:attribute name="class">active nav-link</xsl:attribute>
                          </xsl:if>
                        </xsl:otherwise>
                      </xsl:choose>

                      <xsl:value-of select="$tabName" />

                      <xsl:if test="@type and $MIR.Layout.Abstract.Type.Classification and @xml:lang">
                        <sup class="mir-abstract-tab-lang">
                          <xsl:value-of select="@xml:lang"/>
                        </sup>
                      </xsl:if>
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
              <div class="tab-content">
                <xsl:for-each select="$abstracts/mods:abstract">
                  <xsl:sort select="@type"/>
                  <xsl:sort select="@xml:lang"/>

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
                        <xsl:if test="position() = 1 and not($first-abstract-in-current-lang-position &gt;0)">
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
