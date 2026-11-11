<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='no-access']" mode="object-action">
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="$guest and not($write)">
      <li class="mir-action-item mir-action-item-no-access">
        <a href="{$LoginDetourURL}" class="dropdown-item">
          <xsl:value-of select="mcri18n:translate('mir.actions.noaccess')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="action[@name='no-rights']" mode="object-action">
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />
    <xsl:param name="delete" as="xs:boolean" tunnel="yes" />
    <xsl:param name="guest" as="xs:boolean" tunnel="yes" />

    <xsl:if test="not($guest) and not($write or $delete)">
      <li class="mir-action-item mir-action-item-no-rights">
        <a href="{$LoginDetourURL}" class="dropdown-item">
          <xsl:value-of select="mcri18n:translate('mir.actions.norights')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
