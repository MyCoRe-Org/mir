<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='edit']" mode="result-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />

    <xsl:if test="$write">
      <xsl:variable name="edit-url" select="mirobject:edit-url($object-id)" />
      <li>
        <a class="hit_option hit_edit dropdown-item" href="{if (string-length($edit-url) &gt; 0) then $edit-url else '#'}">
          <span class="fas fa-pencil-alt"></span>
          <xsl:value-of select="mcri18n:translate(if (string-length($edit-url) &gt; 0) then 'object.editObject' else 'object.locked')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
