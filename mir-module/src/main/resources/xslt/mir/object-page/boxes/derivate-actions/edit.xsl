<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='edit']" mode="derivate-action">
    <xsl:param name="derivate-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />

    <xsl:if test="$write">
      <li>
        <a href="{$WebApplicationBaseURL}editor/editor-derivate.xed?derivateid={$derivate-id}&amp;cancelUrl={encode-for-uri($RequestURL)}" class="option dropdown-item">
          <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.updateDerivateName')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
