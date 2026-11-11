<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='copy']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="(not($guest) or $write) and mcracl:check-permission('', 'create-mods')">
      <xsl:variable name="copy-url" select="string(mcractionmapping:get-url-for-id('create-copy', $object-id, true()))" />
      <xsl:if test="string-length($copy-url) &gt; 0">
        <li class="mir-action-item mir-action-item-copy-object">
          <a href="{$copy-url}?copyofid={$object-id}" class="dropdown-item">
            <xsl:value-of select="mcri18n:translate('object.copyObject')" />
          </a>
        </li>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="action[@name='new-version']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="(not($guest) or $write) and mcracl:check-permission('', 'create-mods')">
      <xsl:variable name="copy-url" select="string(mcractionmapping:get-url-for-id('create-copy', $object-id, true()))" />
      <xsl:if test="string-length($copy-url) &gt; 0">
        <li class="mir-action-item mir-action-item-copy-object-new-version">
          <a href="{$copy-url}?oldVersion={$object-id}" class="dropdown-item">
            <xsl:value-of select="mcri18n:translate('object.newVersion')" />
          </a>
        </li>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
