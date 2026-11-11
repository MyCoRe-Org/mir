<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirobject:mods" as="element(mods:mods)?">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:sequence select="$object/metadata/def.modsContainer/modsContainer/mods:mods" />
  </xsl:function>

  <xsl:function name="mirobject:edit-url" as="xs:string">
    <xsl:param name="id" as="xs:string" />

    <xsl:variable name="url" select="string(mcractionmapping:get-url-for-id('update', $id, true()))" />
    <xsl:sequence select="if ($url = '') then '' else string(mcrurl:set-param($url, 'id', $id))" />
  </xsl:function>

</xsl:stylesheet>
