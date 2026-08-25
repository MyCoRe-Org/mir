<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/characteristics.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:if test="not(mcracl:is-current-user-in-role('guest'))">
      <!-- TODO should be @type -->
      <xsl:variable name="characteristics-extension" select="
        metadata/def.modsContainer/modsContainer/mods:mods/mods:extension[@displayLabel='characteristics']
      " />

      <xsl:if test="$characteristics-extension">
        <xsl:call-template name="meta-row">
          <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.characteristics'" />
          <xsl:with-param name="value">
            <xsl:call-template name="characteristics-table">
              <xsl:with-param name="chars" select="$characteristics-extension/chars" />
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="characteristics-table">
    <xsl:param name="chars" as="element(chars)*" />

    <table class="table table-condensed">
      <tr>
        <th>
          <xsl:value-of select="mcri18n:translate('component.mods.metaData.dictionary.year')" />
        </th>
        <th>
          <xsl:value-of select="mcri18n:translate('component.mods.metaData.dictionary.impact')" />
        </th>
        <th>
          <xsl:value-of select="mcri18n:translate('component.mods.metaData.dictionary.refereed')" />
        </th>
      </tr>
      <xsl:for-each select="$chars">
        <tr>
          <td>
            <xsl:value-of select="@year" />
          </td>
          <td>
            <xsl:value-of select="@factor" />
          </td>
          <td>
            <xsl:if test="@refereed">
              <xsl:value-of select="
                mcri18n:translate('component.mods.metaData.dictionary.refereed.' || @refereed)
              " />
            </xsl:if>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

</xsl:stylesheet>
