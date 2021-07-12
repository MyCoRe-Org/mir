<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    exclude-result-prefixes=" i18n mods mcrmods mcrxsl xlink encoder">
  <xsl:import href="xslImport:modsmeta" />
  <xsl:include href="layout/mir-layout-utils.xsl" />
  <xsl:include href="mods-utils.xsl" />
  <xsl:include href="mir-mods-utils.xsl" />
  <xsl:key use="@id" name="rights" match="/mycoreobject/rights/right" />
  <xsl:variable name="mods-type">
    <xsl:apply-templates mode="mods-type" select="." />
  </xsl:variable>
  <xsl:template match="/">
    <site ID="{mycoreobject/@ID}">
      <xsl:if test="key('rights', mycoreobject/@ID)/@read">
        <xsl:attribute name="read"/>
      </xsl:if>
      <xsl:if test="key('rights', mycoreobject/@ID)/@write">
        <xsl:attribute name="write"/>
      </xsl:if>
      <xsl:attribute name="title">
        <xsl:apply-templates mode="mods.title" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods">
          <xsl:with-param name="asHTML" select="false()" />
          <xsl:with-param name="withSubtitle" select="false()" />
        </xsl:apply-templates>
      </xsl:attribute>
      <xsl:call-template name="debug-rights" />
      <xsl:variable name="docState" select="//servstates/servstate/@categid" />
      <xsl:choose>
        <xsl:when test="key('rights', mycoreobject/@ID)/@read">
          <xsl:choose>
            <xsl:when test="key('rights', mycoreobject/@ID)/@write">
              <xsl:apply-imports />
            </xsl:when>
            <xsl:when test="$docState='blocked' or $docState='deleted'">
              <xsl:call-template name="printMirMessage">
                <xsl:with-param name="title" select="i18n:translate(concat('mir.error.', $docState))" />
                <xsl:with-param name="msg">
                  <xsl:if test="//mods:note[@type='admin']">
                    <xsl:for-each select="//mods:note[@type='admin']">
                      <xsl:value-of select="." />
                    </xsl:for-each>
                  </xsl:if>
                  <xsl:variable name="hitsPrecending"
                                select="document(concat('solr:q=',encoder:encode(concat('mods.relatedItem.preceding:', mycoreobject/@ID)), '&amp;rows=1000&amp;sort=mods.dateIssued desc,mods.dateIssued.host desc,mods.title.main desc&amp;group=true&amp;group.limit=100&amp;group.field=mods.yearIssued'))/response/lst[@name='grouped']/lst[@name='mods.yearIssued']" />
                  <xsl:if test="$hitsPrecending/int[@name='matches'] &gt; 0">
                    <xsl:call-template name="listRelatedItems">
                      <xsl:with-param name="hits" select="$hitsPrecending" />
                      <xsl:with-param name="label" select="i18n:translate('mir.metadata.succeedingVersion')" />
                    </xsl:call-template>
                  </xsl:if>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-imports />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <div id="mir-message">
            <xsl:call-template name="mir.printNotLoggedIn">
              <xsl:with-param name="objectId" select="mycoreobject/@ID" />
              <xsl:with-param name="hasAccessKey"
                select="count(key('rights', mycoreobject/@ID)/@hasAccKey) &gt; 0" />
            </xsl:call-template>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </site>
  </xsl:template>

  <xsl:template name="printMirMessage">
    <xsl:param name="title" />
    <xsl:param name="msg" />
    <div id="mir-message">
      <div class="jumbotron">
        <h1>
          <xsl:value-of select="$title" />
        </h1>
        <xsl:if test="$msg">
          <p>
            <xsl:copy-of select="$msg" />
          </p>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="debug-rights">
    <xsl:variable name="lbr" select="'&#x0a;'" />
    <xsl:comment>
      <xsl:value-of select="concat('Permissions:',$lbr,$lbr)" />
      <xsl:for-each select="/mycoreobject/rights/right">
        <xsl:value-of select="concat(@id,': ')" />
        <xsl:for-each select="@*[not(name()='id')]">
          <xsl:value-of select="concat(' ',name())" />
        </xsl:for-each>
        <xsl:value-of select="$lbr" />
      </xsl:for-each>
    </xsl:comment>
  </xsl:template>

  <xsl:template name="categorySearchLink">
    <xsl:param name="class" />
    <xsl:param name="title" />
    <xsl:param name="node" select="." />
    <xsl:param name="parent" select="false()" />
    <xsl:param name="owner" />

    <xsl:variable name="classlink">
      <xsl:choose>
        <xsl:when test="$parent=true()">
          <xsl:value-of select="mcrmods:getClassCategParentLink($node)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcrmods:getClassCategLink($node)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($classlink) &gt; 0">
        <xsl:for-each select="document($classlink)/mycoreclass/categories/category">
          <xsl:variable name="classText">
            <xsl:variable name="selectLang">
              <xsl:call-template name="selectLang">
                <xsl:with-param name="nodes" select="./label" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="./label[lang($selectLang)]">
              <xsl:value-of select="@text" />
            </xsl:for-each>
          </xsl:variable>
          <!-- check for relatedItem containing mycoreobject ID dependent on current user using solr query on field mods.relatedItem -->
          <xsl:variable name="state">
            <xsl:choose>
              <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
                <xsl:text>state:*</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('state:published OR createdby:', $CurrentUser)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="searchLink">
            <xsl:with-param name="class" select="$class" />
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="linkText" select="$classText" />
            <xsl:with-param name="query" select="concat('*&amp;fq=category.top:%22mir_genres:', @ID, '%22 AND (', $state, ' )')" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- xsl:message terminate="yes">
          <xsl:value-of select="concat('not a classification: ',name())" />
        </xsl:message -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="searchLink">
    <xsl:param name="class" />
    <xsl:param name="title" />
    <xsl:param name="linkText" />
    <xsl:param name="query" />
    <a href="{$ServletsBaseURL}solr/find?condQuery={$query}">
      <xsl:if test="$title">
        <xsl:attribute name="title">
          <xsl:value-of select="$title" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$class">
        <xsl:attribute name="class">
          <xsl:value-of select="$class" />
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$linkText" />
    </a>
  </xsl:template>

</xsl:stylesheet>
