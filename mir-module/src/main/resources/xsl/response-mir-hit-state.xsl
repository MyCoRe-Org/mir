<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="i18n mcrxsl xsl">

  <xsl:template name="hit-state">
    <xsl:if test="not (mcrxsl:isCurrentUserGuestUser())">
      <div class="hit_state">
        <xsl:variable name="status-i18n">
          <!-- template in mir-utils.xsl -->
          <xsl:call-template name="get-doc-state-label">
            <xsl:with-param name="state-categ-id" select="str[@name='state']"/>
          </xsl:call-template>
        </xsl:variable>
        <span class="badge mir-{str[@name='state']}"
              title="{i18n:translate('component.mods.metaData.dictionary.status')}">
          <xsl:value-of select="$status-i18n"/>
        </span>
      </div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
