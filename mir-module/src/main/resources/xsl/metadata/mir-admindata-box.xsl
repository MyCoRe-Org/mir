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
              <!--*** publication status ************************************* -->
              <tr>
                <td class="metaname">
                  <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.status'),':')" />
                </td>
                <td class="metavalue">
                  <xsl:call-template name="printClass">
                    <xsl:with-param select="mycoreobject/service/servstates/servstate" name="nodes" />
                  </xsl:call-template>
                </td>
              </tr>
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='createdate']" name="nodes" />
                <xsl:with-param select="i18n:translate('metaData.createdAt')" name="label" />
              </xsl:call-template>
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/service/servflags/servflag[@type='createdby']" name="nodes" />
                <xsl:with-param select="i18n:translate('metaData.createdby')" name="label" />
              </xsl:call-template>
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:note" name="nodes" />
                <xsl:with-param select="i18n:translate('mir.comment')" name="label" />
              </xsl:call-template>
              <!--*** Last Modified ************************************* -->
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='modifydate']" name="nodes" />
                <xsl:with-param select="i18n:translate('metaData.lastChanged')" name="label" />
              </xsl:call-template>
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/service/servflags/servflag[@type='modifiedby']" name="nodes" />
                <xsl:with-param select="i18n:translate('metaData.modifiedBy')" name="label" />
              </xsl:call-template>
              <!--*** MyCoRe-ID and intern ID *************************** -->
              <tr>
                <td class="metaname">
                  <xsl:value-of select="concat(i18n:translate('metaData.ID'),':')" />
                </td>
                <td class="metavalue">
                  <xsl:value-of select="mycoreobject/@ID" />
                </td>
              </tr>
              <xsl:call-template name="printMetaDate">
                <xsl:with-param select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='intern']" name="nodes" />
                <xsl:with-param select="i18n:translate('component.mods.metaData.dictionary.identifier.intern')" name="label" />
              </xsl:call-template>
              <!-- tr>
                <td class="metaname">
                  <xsl:value-of select="concat(i18n:translate('metaData.versions'),' :')" />
                </td>
                <td class="metavalue">
                  <xsl:apply-templates select="." mode="versioninfo" />
                </td>
              </tr -->
              <tr>
                <td class="metaname">
                  <xsl:value-of select="i18n:translate('metadata.versionInfo.version')"/>
                  <xsl:text>:</xsl:text>
                </td>
                <td class="metavalue">
                  <xsl:variable name="verinfo" select="document(concat('versioninfo:',mycoreobject/@ID))" />
                  <xsl:value-of select="count($verinfo/versions/version)" />
                  <br/>
                  <a id="historyStarter" style="cursor: pointer">
                    <xsl:value-of select="i18n:translate('metadata.versionInfo.startLabel')" />
                  </a>
                </td>
              </tr>
            </table>
          </div>
        </div>

    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>