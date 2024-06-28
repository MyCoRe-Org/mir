<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:modsmeta:metadata/export-extension.xsl" />

  <xsl:template match="/">
    <xsl:variable name="objectId" select="/mycoreobject/@ID" />
    <xsl:if test="$mods-type='software'">
      <div id="export-extension">
        <xsl:call-template name="printSeparator" />
        <xsl:call-template name="exportLink">
          <xsl:with-param name="transformer" select="'mods2codemeta-jsonld'"/>
          <xsl:with-param name="linkText" select="'CodeMeta'"/>
          <xsl:with-param name="objectId" select="$objectId" />
        </xsl:call-template>
        <script>
          $(document).ready(function() {
            const exportPanel = $("div#mir-export-panel").find("div.card-body");
            const extensionDiv = $("div#export-extension-div");
            exportPanel.find("a:last-child").after(extensionDiv.children("span, a"));
            extensionDiv.remove();
          });
        </script>
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>
</xsl:stylesheet>
