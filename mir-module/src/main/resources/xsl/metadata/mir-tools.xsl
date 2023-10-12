<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods">
  <xsl:import href="xslImport:modsmeta:metadata/mir-tools.xsl" />
  <!-- TODO: resolve dependencies -->
  <xsl:include href="mods.xsl" />
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <xsl:variable name="objectRights" select="key('rights', mycoreobject/@ID)" />
    <xsl:variable name="write" select="boolean($objectRights/@write)" />
    <xsl:variable name="delete" select="boolean($objectRights/@delete)" />
    <div id="mir-tools">

      <div class="d-flex justify-content-between">

        <ul class="nav d-flex mir-document-hotkeys">
          <li class="nav-item">
            <a class="btn btn-secondary btn-sm nav-link active" href="#">Active</a>
          </li>
          <li class="nav-item">
            <a class="btn btn-secondary btn-sm nav-link" href="#" role="button">Link</a>
          </li>
          <li class="nav-item">
            <a class="btn btn-secondary btn-sm nav-link" href="#">Link</a>
          </li>
        </ul>

        <ul class="nav d-flex justify-content-end mir-document-options">
          <li class="nav-item dropdown">
            <a
              class="nav-link dropdown-toggle btn btn-secondary btn-sm"
              data-toggle="dropdown" href="#"
              role="button"
              aria-expanded="false">
              <i class="fas fa-cog"></i>
              Aktionen
            </a>
            <div class="dropdown-menu dropdown-menu-right">
              <a class="dropdown-item" href="#">Action</a>
              <a class="dropdown-item" href="#">Another action</a>
              <a class="dropdown-item" href="#">Something else here</a>
              <div class="dropdown-divider"></div>
              <a class="dropdown-item" href="#">Separated link</a>
            </div>
          </li>
        </ul>

      </div>

      <!--
      <xsl:apply-templates select="mycoreobject" mode="objectActions">
        <xsl:with-param name="accessedit" select="$write" />
        <xsl:with-param name="accessdelete" select="$delete" />
        <xsl:with-param name="mods-type" select="$mods-type" />
      </xsl:apply-templates>
      -->

    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>