<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='zip']" mode="derivate-action">
    <xsl:param name="derivate-id" as="xs:string" tunnel="yes" />

    <li>
      <a href="{$ServletsBaseURL}MCRZipServlet/{$derivate-id}" class="option downloadzip dropdown-item">
        <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.zip')" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
