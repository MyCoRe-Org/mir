<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mirguidancepanel="http://www.mycore.de/xslt/mirguidancepanel"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirguidancepanel:is-enabled" as="xs:boolean">
    <xsl:sequence select="lower-case(mcrproperty:get('MIR.GuidancePanel.Enabled')) = 'true'" />
  </xsl:function>

  <xsl:function name="mirguidancepanel:is-rss-enabled" as="xs:boolean">
    <xsl:sequence select="lower-case(mcrproperty:get('MIR.GuidancePanel.RSS.Enabled')) = 'true'" />
  </xsl:function>

  <!-- label in the current language, falls back to the default language and then to the first label -->
  <xsl:function name="mirguidancepanel:label" as="xs:string">
    <xsl:param name="labels" as="element(label)*" />
    <xsl:param name="current-lang" as="xs:string" />
    <xsl:param name="default-lang" as="xs:string" />
    <xsl:sequence select="string(($labels[lang($current-lang)], $labels[lang($default-lang)], $labels)[1])" />
  </xsl:function>

</xsl:stylesheet>
