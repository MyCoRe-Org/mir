<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='mets-editor']" mode="derivate-action">
    <xsl:param name="derivate-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />

    <xsl:if test="$write and normalize-space(mcrproperty:get('MIR.METSEditor.enable')) = 'true'
      and string(document(concat('callJava:org.mycore.iview2.services.MCRIView2Tools:getSupportedMainFile:', $derivate-id)))">
      <li>
        <a href="{$WebApplicationBaseURL}rsc/mets/editor/start/{$derivate-id}" class="option startmets dropdown-item">
          <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.startmets')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
