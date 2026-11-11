<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='delete']" mode="derivate-action">
    <xsl:param name="derivate-id" as="xs:string" tunnel="yes" />
    <xsl:param name="delete" as="xs:boolean" tunnel="yes" />

    <xsl:if test="$delete">
      <li class="last">
        <a href="{$ServletsBaseURL}derivate/delete?id={$derivate-id}" class="confirm_deletion option dropdown-item" data-text="{mcri18n:translate('mir.confirm.derivate.text')}">
          <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.delDerivate')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
