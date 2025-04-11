<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:encoder="xalan://java.net.URLEncoder"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="xsl mods mcrxml mcrmods encoder i18n">

  <xsl:include href="resource:xsl/badges/template/create-badge-util.xsl" />

  <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

  <!-- Category badge -->
  <xsl:template name="category-badge">
    <xsl:for-each select="$mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern']">

      <xsl:variable name="classlink" select="mcrmods:getClassCategLink(.)" />

      <xsl:if test="string-length($classlink) &gt; 0">
        <xsl:for-each select="document($classlink)/mycoreclass/categories/category">
          <xsl:variable name="classText" select="./label[lang($CurrentLang)]/@text" />

          <xsl:variable name="state">
            <xsl:choose>
              <xsl:when test="mcrxml:isCurrentUserInRole('admin') or mcrxml:isCurrentUserInRole('editor')">
                <xsl:text>state:*</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>state:published OR createdby:</xsl:text>
                <xsl:value-of select="$CurrentUser" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="categoryId" select="@ID" />

          <xsl:call-template name="create-badge">
            <xsl:with-param name="label" select="$classText" />
            <xsl:with-param name="color" select="'info'" />
            <xsl:with-param name="class" select="'mods_genre'" />
            <xsl:with-param name="URL"
                            select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=category.top:%22mir_genres:',
                      $categoryId, '%22%20AND%20(', encoder:encode($state), ')')" />
            <xsl:with-param name="tooltip" select="i18n:translate('mir.badge.category.tooltip')"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
