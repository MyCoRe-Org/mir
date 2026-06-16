<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="xslImport:mirworkflow:metadata/mir-workflow-hook.xsl"/>

  <xsl:template match="mycoreobject" mode="creatorSubmittedAdd"/>
  <xsl:template match="mycoreobject" mode="editorReviewAdd"/>

</xsl:stylesheet>

