<?xml version="1.0" encoding="UTF-8"?>

<!-- ============================================== -->
<!-- $Revision: 1.2 $ $Date: 2007-02-21 12:14:30 $ -->
<!-- ============================================== -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:acl="xalan://org.mycore.access.MCRAccessManager">

  <xsl:output method="xml" encoding="UTF-8" />
  <xsl:include href="copynodes.xsl" />
  <xsl:include href="xslInclude:mycoreobjectXML" />

  <xsl:template match="mycoreobject">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
	<!-- check the READ permission -->
      <xsl:if test="acl:checkPermission(@ID,'read')">
        <xsl:apply-templates select="node()" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
