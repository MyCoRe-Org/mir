<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='edit']" mode="result-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />

    <xsl:if test="mcracl:check-permission($object-id, 'writedb')">
      <xsl:variable name="edit-url">
        <xsl:call-template name="mods.getObjectEditURL">
          <xsl:with-param name="id" select="$object-id" />
          <xsl:with-param name="layout" select="'$'" />
        </xsl:call-template>
      </xsl:variable>
      <li>
        <a class="hit_option hit_edit dropdown-item" href="{if (string-length($edit-url) &gt; 0) then $edit-url else '#'}">
          <span class="fas fa-pencil-alt"></span>
          <xsl:value-of select="mcri18n:translate(if (string-length($edit-url) &gt; 0) then 'object.editObject' else 'object.locked')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
