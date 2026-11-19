<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='test']" mode="derivate-action">
    <xsl:param name="derivate" as="element(derobject)" tunnel="yes" />
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />

    <li>
      <a class="test" data-object-id="{$object-id}" data-derivate-id="{$derivate/@xlink:href}" />
    </li>
  </xsl:template>

</xsl:stylesheet>
