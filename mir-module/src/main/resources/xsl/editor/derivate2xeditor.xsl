<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xed="http://www.mycore.de/xeditor" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mir="http://www.mycore.de/mir" version="1.0"
                exclude-result-prefixes="xsl mir i18n">

  <xsl:include href="copynodes.xsl"/>

  <xsl:template match="classification[@classid and @categid]">
    <classification><xsl:value-of select="@classid"/>:<xsl:value-of select="@categid"/></classification>
  </xsl:template>

</xsl:stylesheet>