<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="i18n mods xlink mcrxsl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-admindata-box.xsl" />
  <!-- copied from http://www.loc.gov/standards/mods/v3/MODS3-4_HTML_XSLT1-0.xsl -->
  <xsl:template match="/">
    <xsl:variable name="ID" select="/mycoreobject/@ID" />
    <div id="mir-admindata">
      <xsl:copy-of select="document(concat('staticcontent:mir-admindata-box:', $ID))/div" />
    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>