<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='md5']" mode="derivate-action">
    <li>
      <a href="#" class="option dropdown-item toggleMD5Link">
        <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.MD5.show')" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
