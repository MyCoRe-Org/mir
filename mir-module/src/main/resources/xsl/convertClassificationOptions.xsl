<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="mcrxml">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="option">
    <xsl:copy>
      <xsl:attribute name="value">
        <xsl:value-of select="mcrxml:regexp(@value,'_', ' ')"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*[name()!='value']|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
