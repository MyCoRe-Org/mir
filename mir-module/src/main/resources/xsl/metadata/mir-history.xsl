<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:modsmeta:metadata/mir-history.xsl" />  
  
  <xsl:template match="/">
    <xsl:variable name="ID" select="/mycoreobject/@ID" />
    <div id="mir-historydata" class="table-responsive col-sm-12">
      <xsl:copy-of select="document(concat('staticcontent:mir-history:', $ID))" />
    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
