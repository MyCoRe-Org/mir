<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='test']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />

    <li class="mir-action-item mir-action-item-test" data-genres="{@genres}">
      <xsl:value-of select="$object-id" />
    </li>
  </xsl:template>

  <xsl:template match="action[@name='edit'][contains-token(@genres, 'thesis')]" mode="object-action" priority="1">
    <li class="mir-action-item mir-action-item-edit-thesis" />
  </xsl:template>

  <xsl:template match="action[@name='test']" mode="object-action-dialog">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />

    <div id="test-dialog" data-object-id="{$object-id}" data-write="{$write}" data-genres="{@genres}" />
  </xsl:template>

</xsl:stylesheet>
