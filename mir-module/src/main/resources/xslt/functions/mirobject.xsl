<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirobject:mods" as="element(mods:mods)?">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:sequence select="$object/metadata/def.modsContainer/modsContainer/mods:mods" />
  </xsl:function>

</xsl:stylesheet>
