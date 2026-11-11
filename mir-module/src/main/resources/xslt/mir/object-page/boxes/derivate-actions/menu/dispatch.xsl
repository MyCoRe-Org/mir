<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirconfig="http://www.mycore.de/xslt/mirconfig"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode name="derivate-action" on-no-match="deep-skip" on-multiple-match="fail" />

  <xsl:template name="derivate-actions">
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:param name="names" select="mirconfig:get-list('MIR.DerivateActions', ())" as="xs:string*" />

    <xsl:if test="exists($names) and mcracl:check-permission($derivate-id, 'read')">
      <xsl:variable name="actions">
        <xsl:for-each select="$names">
          <action name="{.}" />
        </xsl:for-each>
      </xsl:variable>
      <div class="dropdown float-end options">
        <div class="btn-group">
          <a href="#" class="btn btn-secondary dropdown-toggle" data-bs-toggle="dropdown">
            <i class="fas fa-cog"></i>
            <xsl:value-of select="concat(' ', mcri18n:translate('mir.actions'))" />
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <xsl:apply-templates select="$actions/action" mode="derivate-action">
              <xsl:with-param name="derivate-id" select="$derivate-id" tunnel="yes" />
              <xsl:with-param name="write" select="mcracl:check-permission($derivate-id, 'writedb')" tunnel="yes" />
              <xsl:with-param name="delete" select="mcracl:check-permission($derivate-id, 'deletedb')" tunnel="yes" />
            </xsl:apply-templates>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
