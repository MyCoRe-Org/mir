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

      <div class="mir-document-options">
        <ul class="nav d-flex">
          <li class="nav-item">
            <a class="btn btn-primary btn-sm nav-link" href="#">
              <i class="fas fa-bookmark"></i>
              Merken</a>
          </li>
          <li class="nav-item">
            <a class="btn btn-primary btn-sm nav-link" href="#" role="button">
              <i class="fas fa-download"></i>
              Download</a>
          </li>
          <li class="nav-item">
            <a class="btn btn-primary btn-sm nav-link" href="#">
              <i class="fas fa-pen"></i>
              Bearbeiten</a>
          </li>
          <li class="nav-item dropdown">
            <a
              class="nav-link dropdown-toggle btn btn-outline-primary btn-sm"
              data-toggle="dropdown" href="#"
              role="button"
              aria-expanded="false">
              <i class="fas fa-clone"></i>
              Neu
            </a>
            <div class="dropdown-menu dropdown-menu-right">
              <a class="dropdown-item" href="#">Action</a>
              <a class="dropdown-item" href="#">Another action</a>
              <a class="dropdown-item" href="#">Something else here</a>
              <i class="dropdown-divider"></i>
              <a class="dropdown-item" href="#">Separated link</a>
            </div>
          </li>
          <li class="nav-item dropdown">
            <a
              class="nav-link dropdown-toggle btn btn-outline-primary btn-sm"
              data-toggle="dropdown" href="#"
              role="button"
              aria-expanded="false">
              <i class="fas fa-cog"></i>
              Weiteres
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