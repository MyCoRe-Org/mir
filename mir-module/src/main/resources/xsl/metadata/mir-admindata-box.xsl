<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-admindata-box.xsl" />
  <!-- copied from http://www.loc.gov/standards/mods/v3/MODS3-4_HTML_XSLT1-0.xsl -->
  <xsl:template match="/">
    <div id="mir-admindata">

        <div id="system_box" class="detailbox">
          <h4 id="system_switch" class="block_switch">
            <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.systembox')" />
          </h4>
          <div id="system_content" class="block_content">
            <table class="metaData">
              <xsl:apply-templates mode="present" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:classification" />
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='createdate']" name="nodes" />
                <xsl:with-param select="i18n:translate('metaData.createdAt')" name="label" />
              </xsl:call-template>
              <!--*** Last Modified ************************************* -->
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='modifydate']" name="nodes" />
                <xsl:with-param select="i18n:translate('metaData.lastChanged')" name="label" />
              </xsl:call-template>
              <!--*** MyCoRe-ID ************************************* -->
              <tr>
                <td class="metaname">
                  <xsl:value-of select="concat(i18n:translate('metaData.ID'),':')" />
                </td>
                <td class="metavalue">
                  <xsl:value-of select="mycoreobject/@ID" />
                </td>
              </tr>
              <tr>
                <td class="metaname">
                  <xsl:value-of select="concat(i18n:translate('metaData.versions'),' :')" />
                </td>
                <td class="metavalue">
                  <!-- xsl:apply-templates select="." mode="versioninfo" / -->
                </td>
              </tr>
            </table>
          </div>
        </div>

    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>