<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="i18n xsl mcrxsl mods xlink">

  <!-- Access condition badge -->
  <xsl:template name="access-condition-badge">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

    <xsl:variable name="accessCondition" select="substring-after(normalize-space($mods/mods:accessCondition[@type='use and reproduction']/@xlink:href),'#')" />

    <xsl:if test="$accessCondition">
      <div class="badge-item">

        <xsl:for-each select="$mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern']">

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
            <!-- Here you can add a tooltip -->
            <!-- xsl:with-param name="title" select="'test'"/ -->
          </xsl:call-template>

        </xsl:for-each>
      </div>

    </xsl:if>

  </xsl:template>

</xsl:stylesheet>
