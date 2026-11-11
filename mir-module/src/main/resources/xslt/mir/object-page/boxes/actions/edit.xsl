<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='edit']" mode="object-action">
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="edit-url" as="xs:string" tunnel="yes" />

    <xsl:if test="$write">
      <xsl:choose>
        <xsl:when test="$edit-url != ''">
          <li class="mir-action-item mir-action-item-edit-object">
            <a href="{$edit-url}" class="dropdown-item">
              <xsl:value-of select="mcri18n:translate('object.editObject')" />
            </a>
          </li>
        </xsl:when>
        <xsl:otherwise>
          <li class="dropdown-item">
            <xsl:value-of select="mcri18n:translate('object.locked')" />
          </li>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="action[@name='edit-admin']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="edit-url" as="xs:string" tunnel="yes" />

    <xsl:if test="$write and $edit-url != ''">
      <xsl:variable name="admin-edit-url" select="string(mcractionmapping:get-url-for-id('update-admin', $object-id, true()))" />
      <xsl:if test="string-length($admin-edit-url) &gt; 0">
        <li class="mir-action-item mir-action-item-edit-object-admin">
          <a href="{$admin-edit-url}&amp;id={$object-id}" class="dropdown-item">
            <xsl:value-of select="mcri18n:translate('mir.admineditor')" />
          </a>
        </li>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="action[@name='edit-xml']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="not($guest) or $write">
      <xsl:variable name="edit-xml-url" select="string(mcractionmapping:get-url-for-id('update-xml', $object-id, true()))" />
      <xsl:if test="string-length($edit-xml-url) &gt; 0">
        <li>
          <a href="{$edit-xml-url}{$object-id}" class="dropdown-item">
            <xsl:value-of select="mcri18n:translate('component.mods.object.editAllModsXML')" />
          </a>
        </li>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
