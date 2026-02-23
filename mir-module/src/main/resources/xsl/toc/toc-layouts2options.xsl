<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
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