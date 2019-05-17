<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
>
  
  <xsl:template match="/toc-layouts">
    <options>
      <xsl:for-each select="toc-layout">
        <option value="{@id}">
          <xsl:value-of select="label" />
        </option>
      </xsl:for-each>
    </options>
  </xsl:template>

 </xsl:stylesheet>