<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xpf="http://www.w3.org/2005/xpath-functions" 
  exclude-result-prefixes="xsl xpf">

  <xsl:output method="xml" />
  
  <xsl:template match="xpf:*[@key]">
    <xsl:if test="(count(*) &gt; 0) or (string-length(text()) &gt; 0)">
      <xsl:element name="{@key}">
        <xsl:apply-templates select="*|text()" />
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xpf:map[not(@key)]">
    <entry>
      <xsl:apply-templates select="*" />
    </entry>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:copy-of select="." />
  </xsl:template>

</xsl:stylesheet>
