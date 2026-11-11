<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="dbtypes" select="document('resource:setup/dbtypes.xml')" />

  <xsl:template match="wizard">
    <wizard>
      <xsl:apply-templates select="@*|*" />
    </wizard>
  </xsl:template>

  <xsl:template match="database">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:copy-of select="$dbtypes//db[driver = current()/driver]/library" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mcr-properties">
    <xsl:variable name="rawMode" select="../solr/mode" />
    <xsl:variable name="mode">
      <xsl:choose>
        <xsl:when test="string-length($rawMode) &gt; 0"><xsl:value-of select="$rawMode" /></xsl:when>
        <xsl:otherwise>standalone</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="isStandalone" select="$mode = 'standalone'" />
    <xsl:variable name="isCloudZk" select="$mode = 'cloud-zk'" />
    <xsl:variable name="isCloud" select="$mode = 'cloud-url' or $mode = 'cloud-zk'" />

    <xsl:variable name="serverUrl" select="../solr/serverUrl" />
    <xsl:variable name="zkUrl" select="../solr/zkUrl" />
    <xsl:variable name="zkChroot" select="../solr/zkChroot" />

    <xsl:copy>
      <!-- Copy all properties, filtering out those that don't match the current mode -->
      <xsl:for-each select="property">
        <xsl:variable name="n" select="@name" />
        <xsl:choose>
          <!-- Skip standalone-only properties in cloud mode -->
          <xsl:when test="$isCloud and contains($n, '.CoreName')" />
          <!-- Skip cloud-only properties in standalone mode -->
          <xsl:when test="$isStandalone and contains($n, '.CollectionName')" />
          <!-- Skip SolrUrls in cloud-zk mode -->
          <xsl:when test="$isCloudZk and contains($n, '.SolrUrls')" />
          <!-- Skip ZkUrls/ZkChroot in non-zk modes -->
          <xsl:when test="not($isCloudZk) and (contains($n, '.ZkUrls') or contains($n, '.ZkChroot'))" />
          <xsl:otherwise>
            <xsl:copy-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <!-- Add Class properties based on mode -->
      <xsl:choose>
        <xsl:when test="$isStandalone">
          <property name="MCR.Solr.IndexRegistry.Index.main.Class">org.mycore.solr.standalone.core.MCRConfigurableSolrCore</property>
          <property name="MCR.Solr.IndexRegistry.Index.classification.Class">org.mycore.solr.standalone.core.MCRConfigurableSolrCore</property>
        </xsl:when>
        <xsl:otherwise>
          <property name="MCR.Solr.IndexRegistry.Index.main.Class">org.mycore.solr.cloud.collection.MCRConfigurableSolrCloudCollection</property>
          <property name="MCR.Solr.IndexRegistry.Index.classification.Class">org.mycore.solr.cloud.collection.MCRConfigurableSolrCloudCollection</property>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Add URL/connection properties from shared wizard/solr/* fields -->
      <xsl:choose>
        <xsl:when test="$isStandalone">
          <xsl:if test="string-length($serverUrl) &gt; 0">
            <property name="MCR.Solr.IndexRegistry.Index.main.SolrUrl"><xsl:value-of select="$serverUrl" /></property>
            <property name="MCR.Solr.IndexRegistry.Index.classification.SolrUrl"><xsl:value-of select="$serverUrl" /></property>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$mode = 'cloud-url'">
          <xsl:if test="string-length($serverUrl) &gt; 0">
            <property name="MCR.Solr.IndexRegistry.Index.main.SolrUrls"><xsl:value-of select="$serverUrl" /></property>
            <property name="MCR.Solr.IndexRegistry.Index.classification.SolrUrls"><xsl:value-of select="$serverUrl" /></property>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$isCloudZk">
          <xsl:if test="string-length($zkUrl) &gt; 0">
            <property name="MCR.Solr.IndexRegistry.Index.main.ZkUrls"><xsl:value-of select="$zkUrl" /></property>
            <property name="MCR.Solr.IndexRegistry.Index.classification.ZkUrls"><xsl:value-of select="$zkUrl" /></property>
          </xsl:if>
          <xsl:if test="string-length($zkChroot) &gt; 0">
            <property name="MCR.Solr.IndexRegistry.Index.main.ZkChroot"><xsl:value-of select="$zkChroot" /></property>
            <property name="MCR.Solr.IndexRegistry.Index.classification.ZkChroot"><xsl:value-of select="$zkChroot" /></property>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
