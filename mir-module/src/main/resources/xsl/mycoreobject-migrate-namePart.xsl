<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:mods="http://www.loc.gov/mods/v3">

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="mods-utils.xsl"/>

  <xsl:template match="mods:name[@type='personal']">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
      <xsl:if test="not(mods:namePart[@type='family']) and mods:displayForm">
        <xsl:call-template name="mods.seperateName">
          <xsl:with-param name="displayForm" select="mods:displayForm" />
        </xsl:call-template>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>