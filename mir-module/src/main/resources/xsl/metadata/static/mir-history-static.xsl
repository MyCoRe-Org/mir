<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                version="1.0"
                exclude-result-prefixes="i18n">

  <xsl:template match="/">
    <xsl:variable name="ID" select="/mycoreobject/@ID" />
    <xsl:variable name="verinfo" select="document(concat('versioninfo:', $ID))"/>
    <xsl:copy-of select="$verinfo"/>
  </xsl:template>

</xsl:stylesheet>
