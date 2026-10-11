<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mirseriespanel="http://www.mycore.de/xslt/mirseriespanel"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirseriespanel:is-enabled" as="xs:boolean">
    <xsl:sequence select="lower-case(mcrproperty:get('MIR.SeriesPanel.Enabled')) = 'true'" />
  </xsl:function>

  <xsl:function name="mirseriespanel:is-rss-enabled" as="xs:boolean">
    <xsl:sequence select="lower-case(mcrproperty:get('MIR.SeriesPanel.RSS.Enabled')) = 'true'" />
  </xsl:function>

</xsl:stylesheet>
