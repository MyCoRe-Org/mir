<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
> 

<xsl:output method="xml" encoding="UTF-8"/>

<xsl:variable name="newline">
<xsl:text>
</xsl:text>
</xsl:variable>

<xsl:attribute-set name="tag">
  <xsl:attribute name="class">
    <xsl:value-of select="./@class" />
  </xsl:attribute>
  <xsl:attribute name="heritable">
    <xsl:value-of select="./@heritable" />
  </xsl:attribute>
  <xsl:attribute name="notinherit">
    <xsl:value-of select="./@notinherit" />
  </xsl:attribute>
</xsl:attribute-set>

<xsl:template match="/">
  <mycoreobject>
    <xsl:copy-of select="mycoreobject/@ID"/>
    <xsl:copy-of select="mycoreobject/@label"/>
    <xsl:copy-of select="mycoreobject/@version"/>
    <xsl:copy-of select="mycoreobject/@xsi:noNamespaceSchemaLocation"/>
    <structure>
      <xsl:copy-of select="mycoreobject/structure/parents"/>
    </structure>
    <metadata xml:lang="de">
    <xsl:for-each select="mycoreobject/metadata/*">
<!--
          <xsl:copy-of select="."/>
-->
      <xsl:for-each select="." >
        <xsl:if test="./*/@inherited = '0'">
          <xsl:copy use-attribute-sets="tag">
            <xsl:for-each select="*" >
              <xsl:if test="@inherited = '0'">
                <xsl:copy-of select="."/>
                <xsl:value-of select="$newline"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:copy>
          <xsl:value-of select="$newline"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
    </metadata>
    <service>
      <xsl:apply-templates select="mycoreobject/service/*"/>
	  <!-- include acl if available -->
	  <xsl:variable name="acl" select="document(concat('access:action=all&amp;object=',mycoreobject/@ID))"/>
      <xsl:if test="$acl/*/*">
	    <!-- acl are available -->
	    <xsl:copy-of select="$acl"/>
	  </xsl:if>
   	</service>
  </mycoreobject>
</xsl:template>

<xsl:template match='@*|node()'>
  <xsl:copy>
    <xsl:apply-templates select='@*|node()' />
  </xsl:copy>
</xsl:template>

<xsl:template match="servflags[@class='MCRMetaLangText']">
  <xsl:variable name="accessKeys" select="document(concat('accesskeys:', /mycoreobject/@ID))/servflag" />
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:copy-of select="node()"/>
    <xsl:if test="$accessKeys">
      <xsl:copy-of select="$accessKeys" />
    </xsl:if>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
