<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n">

  <xsl:import href="xslImport:badges:badges/mir-badges-oa.xsl"/>
  <xsl:include href="mir-badges-style-template.xsl"/>

  <xsl:template match="doc" mode="resultList">
    <div class="hit_oa" data-toggle="tooltip">
      <xsl:variable name="isOpenAccess" select="bool[@name='worldReadableComplete']='true'"/>

      <xsl:choose>
        <xsl:when test="$isOpenAccess">
          <xsl:attribute name="title">
            <xsl:value-of select="i18n:translate('mir.response.openAccess.true')"/>
          </xsl:attribute>
          <span class="badge badge-success">
            <i class="fas fa-unlock-alt" aria-hidden="true"/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="title">
            <xsl:value-of select="i18n:translate('mir.response.openAccess.false')"/>
          </xsl:attribute>
          <span class="badge badge-warning">
            <i class="fas fa-lock" aria-hidden="true"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </div>

    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
