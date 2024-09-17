<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl">

  <xsl:param name="MCR.ORCID2.OAuth.ClientSecret" select="''"/>
  <xsl:variable name="isOrcidEnabled" select="string-length($MCR.ORCID2.OAuth.ClientSecret) &gt; 0"/>

</xsl:stylesheet>
