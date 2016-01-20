<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="i18n mods xlink mcrxsl">

  <xsl:import href="xslImport:modsmeta:metadata/mir-abstract.xsl" />

  <xsl:template match="/">

    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

<!-- badges -->
    <div id="mir-abstract-badges">
        <xsl:variable name="dateIssued">
          <xsl:apply-templates mode="mods.datePublished" select="$mods" />
        </xsl:variable>

        <!-- TODO: Update badges -->
        <div id="badges">
          <xsl:call-template name="categorySearchLink">
            <xsl:with-param name="class" select="'mods_genre label label-info'" />
            <xsl:with-param name="node" select="($mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern'])[1]" />
          </xsl:call-template>

          <xsl:if test="string-length($dateIssued) > 0">
            <time itemprop="datePublished" datetime="{$dateIssued}" data-toggle="tooltip" title="Publication date">
              <span class="date_published label label-primary">
                <xsl:variable name="format">
                  <xsl:choose>
                    <xsl:when test="string-length(normalize-space($dateIssued))=4">
                      <xsl:value-of select="i18n:translate('metaData.dateYear')" />
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($dateIssued))=7">
                      <xsl:value-of select="i18n:translate('metaData.dateYearMonth')" />
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($dateIssued))=10">
                      <xsl:value-of select="i18n:translate('metaData.dateYearMonthDay')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="i18n:translate('metaData.dateTime')" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="formatISODate">
                  <xsl:with-param name="date" select="$dateIssued" />
                  <xsl:with-param name="format" select="$format" />
                </xsl:call-template>
              </span>
            </time>
          </xsl:if>

          <xsl:variable name="accessCondition" select="normalize-space($mods/mods:accessCondition[@type='use and reproduction'])" />
          <xsl:if test="$accessCondition">
            <xsl:variable name="linkText">
              <xsl:choose>
                <xsl:when test="contains($accessCondition, 'cc_by')">
                  <xsl:apply-templates select="$mods/mods:accessCondition[@type='use and reproduction']/text()" mode="cc-text" />
                </xsl:when>
                <xsl:when test="contains($accessCondition, 'rights_reserved')">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.rightsReserved')" />
                </xsl:when>
                <xsl:when test="contains($accessCondition, 'oa_nlz')">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.oa_nlz.short')" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$mods/mods:accessCondition[@type='use and reproduction']/text()" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="searchLink">
              <xsl:with-param name="class" select="'access_condition label label-success'" />
              <xsl:with-param name="linkText" select="$linkText" />
              <xsl:with-param name="query" select="concat('%2BallMeta%3A&quot;',$accessCondition,'&quot;')" />
            </xsl:call-template>
          </xsl:if>
        </div><!-- end: badges -->
    </div><!-- end: badgets structure -->


<!-- headline -->
    <div id="mir-abstract-title">
      <h1 itemprop="name">
        <xsl:apply-templates mode="mods.title" select="$mods">
          <xsl:with-param name="withSubtitle" select="true()" />
        </xsl:apply-templates>
      </h1>
    </div>


<!-- authors, description, children -->
    <div id="mir-abstract-plus">

      <xsl:if test="$mods/mods:name[mods:role/mods:roleTerm/text()='aut'] or $mods/mods:name[mods:role/mods:roleTerm/text()='edt']">
        <p id="authors_short">
          <xsl:choose>
            <xsl:when test="$mods/mods:name[mods:role/mods:roleTerm/text()='aut']">
              <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm/text()='aut']">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="'; '" />
                </xsl:if>
                <xsl:apply-templates select="." mode="nameLink" />
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
                <xsl:apply-templates select="." mode="nameLink" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="i18n:translate('mir.abstract.editor')" />
                <xsl:if test="mods:etal">
                  <em>et.al.</em>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </p>
      </xsl:if>

      <xsl:if test="$mods/mods:abstract">

        <xsl:choose>
          <xsl:when test="count($mods/mods:abstract) &gt; 1">

            <div id="mir-abstract-tabs">
              <ul class="nav nav-tabs" role="tablist">
                <xsl:for-each select="$mods/mods:abstract">
                  <xsl:variable name="tabName">
                    <xsl:choose>
                      <xsl:when test="@xml:lang"><xsl:value-of select="@xml:lang" /></xsl:when>
                      <xsl:otherwise><xsl:value-of select="$mods/mods:language/mods:languageTerm[@authority='rfc4646'][@type='code']" /></xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <li class="pull-right">
                    <xsl:if test="position()=1">
                      <xsl:attribute name="class">active pull-right</xsl:attribute>
                    </xsl:if>
                    <a href="#tab{position()}" role="tab" data-toggle="tab">
                      <xsl:value-of select="$tabName" />
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
              <div class="tab-content">
                <xsl:for-each select="$mods/mods:abstract">
                  <div class="tab-pane ellipsis" role="tabpanel" id="tab{position()}">
                    <xsl:if test="position()=1">
                      <xsl:attribute name="class">tab-pane ellipsis active</xsl:attribute>
                    </xsl:if>
                    <p>
                      <span itemprop="description">
                        <xsl:value-of select="." />
                      </span>
                      <a href="#" onclick="javascript: $('.ellipsis').trigger('destroy.dot'); $('.ellipsis').css('height', 'auto'); return false;" title="read more" class="readmore">
                        <xsl:value-of select="i18n:translate('mir.abstract.readmore')" />
                      </a>
                    </p>
                  </div>
                </xsl:for-each>
              </div>
            </div>

          </xsl:when>
          <xsl:otherwise>
            <div class="ellipsis">
              <p>
                <span itemprop="description">
                  <xsl:value-of select="$mods/mods:abstract" />
                </span>
                <a href="#" onclick="javascript: $('.ellipsis').trigger('destroy.dot'); $('.ellipsis').css('height', 'auto'); return false;" title="read more" class="readmore">
                  <xsl:value-of select="i18n:translate('mir.abstract.readmore')" />
                </a>
              </p>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <!-- check for relatedItem containing mycoreobject ID dependent on current user using solr query on field mods.relatedItem -->
      <xsl:variable name="state">
        <xsl:choose>
          <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">state:*</xsl:when>
          <xsl:otherwise>state:published OR createdby:<xsl:value-of select="$CurrentUser" /></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="hits"
                    xmlns:encoder="xalan://java.net.URLEncoder"
                    select="document(concat('solr:q=',encoder:encode(concat('mods.relatedItem:', mycoreobject/@ID, ' AND (', $state, ')')), '&amp;rows=1000&amp;sort=mods.dateIssued desc,mods.part desc&amp;group=true&amp;group.limit=100&amp;group.field=mods.dateIssued'))/response/lst[@name='grouped']/lst[@name='mods.dateIssued']" />
      <xsl:if test="$hits/int[@name='matches'] &gt; 0">
        <h3><xsl:value-of select="i18n:translate('mir.metadata.content')" /></h3>
        <xsl:choose>
          <xsl:when test="$hits/arr[@name='groups']/lst/result/@numFound &gt; 1 and not($hits/arr[@name='groups']/lst/null/@name='groupValue')">
            <ul id="mir_relatedItem">
              <xsl:for-each select="$hits/arr[@name='groups']/lst">
                <li>
                  <span class="glyphicon glyphicon-chevron-right"></span>
                  <span><xsl:value-of select="str[@name='groupValue']" /></span>
                  <ul>
                    <xsl:for-each select="result/doc">
                      <li>
                        <a href="{$WebApplicationBaseURL}/receive/{str[@name='returnId']}">
                          <xsl:if test="str[@name='mods.part'] and not(str[@name='mods.part'] = str[@name='search_result_link_text'])">
                            <xsl:value-of select="str[@name='mods.part']" />
                            <xsl:text> - </xsl:text>
                          </xsl:if>
                          <xsl:value-of select="str[@name='search_result_link_text']" />
                        </a>
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
                  <a href="{$WebApplicationBaseURL}/receive/{str[@name='returnId']}">
                    <xsl:if test="str[@name='mods.part'] and not(str[@name='mods.part'] = str[@name='search_result_link_text'])">
                      <xsl:value-of select="str[@name='mods.part']" />
                      <xsl:text> - </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="str[@name='search_result_link_text']" />
                  </a>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

    </div><!-- end: authors, description, children -->

    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>