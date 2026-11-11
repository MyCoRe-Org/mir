<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrpi="http://www.mycore.de/xslt/pi"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='register-pi']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />

    <xsl:if test="$write">
      <xsl:for-each select="mcrpi:get-pi-service-information($object-id)[@permission='true']">
        <xsl:sort select="@type" />
        <xsl:sort select="@id" />
        <li class="mir-action-item mir-action-item-register-pi mir-action-item-register-{@type}">
          <a href="#" data-type="{@type}" data-mycoreID="{$object-id}" data-baseURL="{$WebApplicationBaseURL}">
            <xsl:attribute name="class">
              <xsl:text>dropdown-item</xsl:text>
              <xsl:if test="@inscribed='true'">
                <xsl:text> disabled</xsl:text>
              </xsl:if>
            </xsl:attribute>
            <xsl:if test="@inscribed='false'">
              <xsl:attribute name="data-register-pi" select="@id" />
            </xsl:if>
            <xsl:value-of select="mcri18n:translate(concat('component.pi.register.', @id))" />
          </a>
        </li>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
