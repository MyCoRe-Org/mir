<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mods="http://www.loc.gov/mods/v3"
                exclude-result-prefixes="i18n xsl mods">

  <xsl:param name="MCR.DOI.Resolver.MasterURL" select="''" />

  <!-- Register only badge -->
  <xsl:template name="register-only-badge">
    <xsl:if test="//mods:classification[contains(@valueURI, 'registerOnly#true')]">

      <xsl:variable name="doi" select="//mods:identifier[@type='doi']" />

      <div class="badge-item">

        <xsl:choose>
          <xsl:when test="$doi">
            <a href="{$MCR.DOI.Resolver.MasterURL}{$doi}"
               class="badge badge-primary mir-abstract-register-only">
              <xsl:value-of select="i18n:translate('mir.registered.record')" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <span class="badge badge-primary mir-abstract-register-only">
              <xsl:value-of select="i18n:translate('mir.registered.record')" />
            </span>
          </xsl:otherwise>
        </xsl:choose>

      </div>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
