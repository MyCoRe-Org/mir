<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

  <xsl:import href="xslImport:modsmeta:metadata/mir-edit.xsl" />
  <!-- TODO: resolve dependencies -->
  <xsl:include href="resource:xsl/mods.xsl" />
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <xsl:variable name="objectRights" select="key('rights', mycoreobject/@ID)" />
    <xsl:variable name="write" select="boolean($objectRights/@write)" />
    <xsl:variable name="delete" select="boolean($objectRights/@delete)" />
    <div id="mir-edit">

        <xsl:apply-templates select="mycoreobject" mode="objectActions">
          <xsl:with-param name="accessedit" select="$write" />
          <xsl:with-param name="accessdelete" select="$delete" />
          <xsl:with-param name="mods-type" select="$mods-type" />
        </xsl:apply-templates>

    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
