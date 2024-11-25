<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="i18n mcrxsl xsl">

  <xsl:template name="hit-licence">
    <xsl:if test="arr[@name='category.top']/str[contains(text(), 'mir_licenses:')]">
      <div class="hit_license">
        <span class="badge badge-primary">
          <xsl:variable name="accessCondition">
            <xsl:value-of
              select="substring-after(arr[@name='category.top']/str[contains(text(), 'mir_licenses:')][last()],':')"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="contains($accessCondition, 'rights_reserved')">
              <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.rightsReserved')"/>
            </xsl:when>
            <xsl:when test="contains($accessCondition, 'oa_nlz')">
              <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.oa_nlz.short')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mcrxsl:getDisplayName('mir_licenses',$accessCondition)"/>
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
