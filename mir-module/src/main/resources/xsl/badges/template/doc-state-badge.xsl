<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n xsl">

  <!-- Doc state badge -->
  <xsl:template name="doc-state-badge">
    <xsl:variable name="doc-state" select="mycoreobject/service/servstates/servstate/@categid" />
    <xsl:if test="$doc-state">
      <div class="badge-item">
        <div class="doc_state">
          <xsl:variable name="status-i18n">
            <!-- template in mir-utils.xsl -->
            <xsl:call-template name="get-doc-state-label">
              <xsl:with-param name="state-categ-id" select="$doc-state"/>
            </xsl:call-template>
          </xsl:variable>
          <span class="badge mir-{$doc-state}" title="{i18n:translate('component.mods.metaData.dictionary.status')}">
            <xsl:value-of select="$status-i18n" />
          </span>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
