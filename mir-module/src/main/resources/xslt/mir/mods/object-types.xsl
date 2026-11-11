<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all" >

  <xsl:include href="resource:xslt/utils/mods-utils.xsl" />
  <xsl:include href="resource:xslt/mir/mods/mods2html.xsl" />

  <xsl:include href="resource:xslt/mir/basket/add-button.xsl" />

  <xsl:include href="resource:xslt/mir/mods/hitlist-external.xsl" />  <!-- for external usage in application module -->
  <xsl:include href="resource:xslt/mir/mods/details-external.xsl" />  <!-- for external usage in application module -->

  <!--Template for title in metadata view: see mycoreobject.xsl -->
  <xsl:template priority="1" mode="title" match="/mycoreobject[contains(@ID,'_mods_')]">
    <xsl:variable name="mods-type">
      <xsl:apply-templates select="." mode="mods-type" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$mods-type='confpro'">
        <xsl:apply-templates select="./metadata/def.modsContainer/modsContainer/mods:mods" mode="mods.title.confpro" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title">
            <xsl:variable name="text">
              <xsl:choose>
                <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@transliteration]/mods:title">
                  <!-- TODO: if editor bug fixed -->
                  <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@transliteration]/mods:title" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[1]" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$text" disable-output-escaping="yes" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@ID" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
