<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="i18n mods xlink mcrxsl xalan"
>

  <xsl:import href="xslImport:modsmeta:metadata/mir-abstract.xsl" />

  <xsl:template match="/">

    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <xsl:variable name="owner">
      <xsl:choose>
        <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
          <xsl:text>*</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$CurrentUser" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- badges -->
    <div id="mir-abstract-badges">
      <xsl:variable name="dateIssued">
        <xsl:choose>
          <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued"><xsl:apply-templates mode="mods.datePublished" select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued" /></xsl:when>
          <xsl:when test="$mods/mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued"><xsl:apply-templates mode="mods.datePublished" select="$mods/mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued" /></xsl:when>
        </xsl:choose>
      </xsl:variable>

        <!-- TODO: Update badges -->
      <div id="badges">
        <xsl:call-template name="categorySearchLink">
          <xsl:with-param name="class" select="'mods_genre label label-info'" />
          <xsl:with-param name="node" select="($mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern'])[1]" />
          <xsl:with-param name="owner"  select="$owner" />
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
            <xsl:with-param name="class" select="'access_condition label label-success'" />
            <xsl:with-param name="linkText" select="$linkText" />
            <xsl:with-param name="query" select="concat('&amp;fq=link:*',$accessCondition, '&amp;owner=createdby:', $owner)" />
          </xsl:call-template>
        </xsl:if>
      </div><!-- end: badges -->
    </div><!-- end: badgets structure -->

    <!-- headline -->
    <div id="mir-abstract-title">
      <h1 itemprop="name">
        <xsl:apply-templates mode="mods.title" select="$mods">
          <xsl:with-param name="asHTML" select="true()" />
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
        <xsl:variable name="aFilter">
          <xsl:for-each select="$mods/mods:abstract">
            <xsl:choose>
              <xsl:when test="(string-length(@altRepGroup) &gt; 0) and (string-length(@altFormat) &gt; 0)">
                <!-- ignore abstract -->
              </xsl:when>
              <xsl:when test="(string-length(@altRepGroup) &gt; 0) and (string-length(@altFormat) = 0)">
                <mods:abstract xml:lang="{@xml:lang}">
                  <xsl:apply-templates select="." mode="mods.printAlternateFormat">
                    <xsl:with-param name="asHTML" select="true()" />
                    <xsl:with-param name="filtered" select="true()" />
                  </xsl:apply-templates>
                </mods:abstract>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="." />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="abstracts" select="xalan:nodeset($aFilter)" />

        <xsl:choose>
          <xsl:when test="count($abstracts/mods:abstract) &gt; 1">

            <div id="mir-abstract-tabs">
              <ul class="nav nav-tabs" role="tablist">
                <xsl:for-each select="$abstracts/mods:abstract">
                  <xsl:variable name="tabName">
                    <xsl:choose>
                      <xsl:when test="@xml:lang">
                        <xsl:value-of
                          select="document(concat('classification:metadata:0:children:rfc4646:',./@xml:lang))//category/label[@xml:lang=$CurrentLang]/@text" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of
                          select="document(concat('classification:metadata:0:children:rfc4646:',$mods/mods:language/mods:languageTerm[@authority='rfc4646'][@type='code']))//category/label[@xml:lang=$CurrentLang]/@text" />
                      </xsl:otherwise>
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
                <xsl:for-each select="$abstracts/mods:abstract">
                  <div class="tab-pane ellipsis ellipsis-text" role="tabpanel" id="tab{position()}">
                    <xsl:if test="position()=1">
                      <xsl:attribute name="class">tab-pane ellipsis ellipsis-text active</xsl:attribute>
                    </xsl:if>
                    <p>
                      <span itemprop="description">
                        <xsl:copy-of select="node()" />
                      </span>
                      <a href="#" class="readless hidden" title="read less">
                        <xsl:value-of select="i18n:translate('mir.abstract.readless')" />
                      </a>
                      <a href="#" class="readmore hidden" title="read more">
                        <xsl:value-of select="i18n:translate('mir.abstract.readmore')" />
                      </a>
                    </p>
                  </div>
                </xsl:for-each>
              </div>
            </div>

          </xsl:when>
          <xsl:otherwise>
            <div class="ellipsis ellipsis-text">
              <p>
                <span itemprop="description">
                  <xsl:apply-templates select="$abstracts/mods:abstract" mode="copyNode" />
                </span>
                <a href="#" class="readless hidden" title="read less">
                  <xsl:value-of select="i18n:translate('mir.abstract.readless')" />
                </a>
                <a href="#" class="readmore hidden" title="read more">
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
        <xsl:with-param name="query" select="concat('(mods.relatedItem.host:', mycoreobject/@ID, ' OR mods.relatedItem.series:', mycoreobject/@ID, ') AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.content')"/>
      </xsl:call-template>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.references:', mycoreobject/@ID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.isReferencedBy')"/>
      </xsl:call-template>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.preceding:', mycoreobject/@ID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.succeeding')"/>
      </xsl:call-template>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.original:', mycoreobject/@ID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.otherVersion')"/>
      </xsl:call-template>

      <xsl:call-template name="findRelatedItems">
        <xsl:with-param name="query" select="concat('mods.relatedItem.reviewOf:', mycoreobject/@ID, ' AND (', $state, ')')"/>
        <xsl:with-param name="label" select="i18n:translate('mir.metadata.review')"/>
      </xsl:call-template>

    </div><!-- end: authors, description, children -->

    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="findRelatedItems">
    <xsl:param name="query"/>
    <xsl:param name="label"/>

    <xsl:variable name="hitsSort" xmlns:encoder="xalan://java.net.URLEncoder"
                  select="document(concat('solr:q=',encoder:encode(concat($query, ' +mods.part.order.',  mycoreobject/@ID, ':[* TO *]')), '&amp;rows=1000&amp;sort=mods.dateIssued desc, mods.dateIssued.host desc, mods.part desc, mods.title.main desc'))" />
    <xsl:variable name="hitsSortList" xmlns:encoder="xalan://java.net.URLEncoder"
                  select="document(concat('solr:q=',encoder:encode($query), '&amp;rows=1000&amp;sort=mods.part.order.', mycoreobject/@ID, ' desc,mods.dateIssued desc, mods.dateIssued.host desc, mods.part desc, mods.title.main desc'))" />
    <xsl:variable name="hits" xmlns:encoder="xalan://java.net.URLEncoder"
                  select="document(concat('solr:q=',encoder:encode($query), '&amp;rows=1000&amp;sort=mods.dateIssued desc, mods.dateIssued.host desc, mods.part desc, mods.title.main desc&amp;group=true&amp;group.limit=100&amp;group.field=mods.yearIssued'))/response/lst[@name='grouped']/lst[@name='mods.yearIssued']" />
    <xsl:choose>
      <xsl:when test="$hitsSort/response/result/@numFound &gt; 0">
        <xsl:call-template name="listSortedRelatedItems">
          <xsl:with-param name="hits" select="$hitsSortList"/>
          <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$hits/int[@name='matches'] &gt; 0">
          <xsl:call-template name="listRelatedItems">
            <xsl:with-param name="hits" select="$hits"/>
            <xsl:with-param name="label" select="$label"/>
          </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="listRelatedItems">
    <xsl:param name="hits"/>
    <xsl:param name="label"/>
    <h3>
      <xsl:value-of select="$label" />
      <xsl:if
              test="$hits/arr[@name='groups']/lst/result/@numFound &gt; 1 and not($hits/arr[@name='groups']/lst/null/@name='groupValue') and count($hits/arr[@name='groups']/lst) &gt; 1"
      >
        <a id="mir_relatedItem_showAll" class="pull-right" href="#">alles ausklappen</a>
        <a id="mir_relatedItem_hideAll" class="pull-right" href="#">alles einklappen</a>
      </xsl:if>
    </h3>
    <xsl:choose>
      <xsl:when
              test="$hits/arr[@name='groups']/lst/result/@numFound &gt; 1 and not($hits/arr[@name='groups']/lst/null/@name='groupValue') and count($hits/arr[@name='groups']/lst) &gt; 1"
      >
        <ul id="mir_relatedItem">
          <xsl:for-each select="$hits/arr[@name='groups']/lst">
            <li>
              <span class="glyphicon glyphicon-chevron-right"></span>
              <span>
                <xsl:value-of select="int[@name='groupValue']" />
              </span>
              <ul>
                <xsl:for-each select="result/doc">
                  <li>
                    <a href="{$WebApplicationBaseURL}receive/{str[@name='returnId']}">
                      <xsl:if test="str[@name='mods.part']">
                        <xsl:value-of select="str[@name='mods.part']" />
                      </xsl:if>
                      <xsl:if test="str[@name='mods.part'] and not(str[@name='mods.title.main'] = str[@name='mods.part'])">
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="str[@name='search_result_link_text']" />
                      </xsl:if>
                      <xsl:if test="not(str[@name='mods.part'])">
                        <xsl:value-of select="str[@name='search_result_link_text']" />
                      </xsl:if>
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
              <a href="{$WebApplicationBaseURL}receive/{str[@name='returnId']}">
                <xsl:if test="str[@name='mods.part']">
                  <xsl:value-of select="str[@name='mods.part']" />
                </xsl:if>
                <xsl:if test="str[@name='mods.part'] and not(str[@name='mods.title.main'] = str[@name='mods.part'])">
                  <xsl:text> - </xsl:text>
                  <xsl:value-of select="str[@name='search_result_link_text']" />
                </xsl:if>
                <xsl:if test="not(str[@name='mods.part'])">
                  <xsl:value-of select="str[@name='search_result_link_text']" />
                </xsl:if>
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="listSortedRelatedItems">
    <xsl:param name="hits"/>
    <xsl:param name="label"/>
    <h3>
      <xsl:value-of select="$label" />
    </h3>
    <ul>
      <xsl:for-each select="$hits/response/result/doc">
        <li>
          <a href="{$WebApplicationBaseURL}receive/{str[@name='returnId']}">
            <xsl:if test="str[@name='mods.part']">
              <xsl:value-of select="str[@name='mods.part']" />
            </xsl:if>
            <xsl:if test="str[@name='mods.part'] and not(str[@name='mods.title.main'] = str[@name='mods.part'])">
              <xsl:text> - </xsl:text>
              <xsl:value-of select="str[@name='search_result_link_text']" />
            </xsl:if>
            <xsl:if test="not(str[@name='mods.part'])">
              <xsl:value-of select="str[@name='search_result_link_text']" />
            </xsl:if>
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

</xsl:stylesheet>