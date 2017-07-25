<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================== -->
<!-- $Revision$ $Date$ -->
<!-- ====================================================================== -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:str="http://exslt.org/strings" exclude-result-prefixes="xsl xalan i18n str"
>

  <xsl:include href="str.tokenize.xsl" />

  <xsl:param name="SortBy" select="''" />
  <xsl:param name="SortOrder" select="''" />
  <xsl:param name="SortType" select="'text'" />
  <xsl:param name="numPerPage" select="10" />
  <xsl:param name="Page" select="1" />
  <xsl:param name="Filter" />

  <xsl:variable name="headerCols">
    <xsl:apply-templates mode="dataTableHeader" select="." />
  </xsl:variable>

  <xsl:variable name="defaultNumPerPage" select="10" />
  <xsl:variable name="defaultSortBy">
    <xsl:value-of
      select="xalan:nodeset($headerCols)/col[(position() = 1) and (string-length(@sortOrder) &gt; 0)]/@sortBy|xalan:nodeset($headerCols)/th[(position() = 1) and (string-length(@sortOrder) &gt; 0)]/@sortBy" />
  </xsl:variable>
  <xsl:variable name="defaultSortOrder">
    <xsl:value-of select="xalan:nodeset($headerCols)/col[1]/@sortOrder|xalan:nodeset($headerCols)/th[1]/@sortOrder" />
  </xsl:variable>

  <xsl:variable name="SortBy">
    <xsl:call-template name="getParam">
      <xsl:with-param name="par" select="'SortBy'" />
      <xsl:with-param name="default" select="$defaultSortBy" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SortOrder">
    <xsl:call-template name="getParam">
      <xsl:with-param name="par" select="'SortOrder'" />
      <xsl:with-param name="default" select="$defaultSortOrder" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="SortType">
    <xsl:variable name="sortType">
      <xsl:call-template name="getParam">
        <xsl:with-param name="par" select="'SortType'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:value-of select="xalan:nodeset($headerCols)/col[1]/@sortType|xalan:nodeset($headerCols)/th[1]/@sortType" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="(string-length($sortType) = 0) and (string-length($type) &gt; 0)">
        <xsl:value-of select="$type" />
      </xsl:when>
      <xsl:when test="string-length($sortType) &gt; 0">
        <xsl:value-of select="$sortType" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>text</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="numPerPage">
    <xsl:call-template name="getParam">
      <xsl:with-param name="par" select="'numPerPage'" />
      <xsl:with-param name="default" select="$defaultNumPerPage" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="Filter">
    <xsl:call-template name="getParam">
      <xsl:with-param name="par" select="'Filter'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="Page">
    <xsl:call-template name="getParam">
      <xsl:with-param name="par" select="'Page'" />
      <xsl:with-param name="default" select="1" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="dataTableNumPerPageList">
    <xsl:text>10,25,50,100</xsl:text>
  </xsl:variable>

  <xsl:template name="getParam" xmlns:decoder="xalan://java.net.URLDecoder">
    <xsl:param name="par" />
    <xsl:param name="default" select="''" />

    <xsl:variable name="urlParam">
      <xsl:call-template name="UrlGetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="$par" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length($urlParam) &gt; 0">
        <xsl:value-of select="decoder:decode(string($urlParam), 'UTF-8')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="dataTable" match="*">
    <xsl:param name="id" select="'dataTable'" />
    <xsl:param name="i18nprefix" select="'dataTable'" />
    <xsl:param name="disableFilter" select="false()" />

    <!-- get total records from root element or count -->
    <xsl:variable name="nativeLimit" select="string-length(@total) &gt; 0" />
    <xsl:variable name="total">
      <xsl:choose>
        <xsl:when test="string-length(@total) &gt; 0">
          <xsl:value-of select="number(@total)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(./*)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pages">
      <xsl:variable name="p">
        <xsl:value-of select="ceiling($total div number($numPerPage))" />
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="($p * number($numPerPage)) &lt; $total">
          <xsl:value-of select="$p + 1" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$p" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="end">
      <xsl:choose>
        <xsl:when test="(number($Page) * number($numPerPage)) &gt; $total">
          <xsl:value-of select="$total" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="(number($Page) * number($numPerPage))" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="start">
      <xsl:choose>
        <xsl:when test="$total = 0">
          <xsl:value-of select="0" />
        </xsl:when>
        <xsl:when test="$Page &gt; $pages">
          <xsl:value-of select="1" />
        </xsl:when>
        <xsl:when test="$end = 0">
          <xsl:value-of select="$end" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="((number($Page) - 1) * number($numPerPage)) + 1" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div id="{$id}_wrapper" class="datatable panel panel-default">
      <div class="panel-heading clearfix">
        <form id="{$id}_form" class="row form-inline" role="form">
          <!-- build hidden values -->
          <xsl:call-template name="dataTableFormValues" />

          <xsl:variable name="colWidth">
            <xsl:choose>
              <xsl:when test="$disableFilter = false()">
                <xsl:value-of select="6" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="12" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:if test="$disableFilter = false()">
            <!-- entries filter -->
            <div class="col-xs-{$colWidth}">
              <div class="form-group no-margin" id="{$id}_filter">
                <label>
                  <span class="glyphicon glyphicon-filter" aria-hidden="true" />
                  <xsl:value-of select="i18n:translate(concat($i18nprefix, '.filter'))" />
                  <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                  <input class="form-control input-sm" type="search" name="Filter">
                    <xsl:attribute name="value">
                      <xsl:if test="string-length($Filter) &gt; 0">
                        <xsl:value-of select="$Filter" />
                      </xsl:if>
                    </xsl:attribute>
                  </input>
                </label>
              </div>
            </div>
          </xsl:if>
          
          <!-- numPerPage selector -->
          <div>
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="$disableFilter = true()">
                  <xsl:value-of select="concat('col-xs-offset-', $colWidth div 2, ' col-xs-', $colWidth div 2)" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat(' col-xs-', $colWidth)" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <div id="{$id}_length" class="form-group pull-right no-margin">
              <label>
                <select class="form-control input-sm" name="numPerPage" size="1" onchange="this.form.submit()">
                  <xsl:variable name="tokens">
                    <xsl:call-template name="str:tokenize">
                      <xsl:with-param name="string" select="$dataTableNumPerPageList" />
                      <xsl:with-param name="delimiters" select="','" />
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:for-each select="xalan:nodeset($tokens)/token">
                    <option value="{.}">
                      <xsl:if test="$numPerPage = .">
                        <xsl:attribute name="selected"><xsl:text>selected</xsl:text></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="." />
                    </option>
                  </xsl:for-each>
                </select>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.lengthMenu'))" />
                <noscript>
                  <input class="btn" type="submit" name="Ok" value="Ok" />
                </noscript>
              </label>
            </div>
          </div>
        </form>
      </div>
      <!-- build DataTable -->
      <div class="table-responsive">
        <table class="table table-striped" id="{$id}">
          <xsl:call-template name="dataTableHeader" />
          <xsl:choose>
            <xsl:when test="number($end) = 0">
              <tr class="odd" align="center">
                <td colspan="{$dataTableHeaderColCount}">
                  <xsl:value-of select="i18n:translate(concat($i18nprefix, '.noItemFound'))" />
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="dataTableBody">
                <xsl:with-param name="nativeLimit" select="$nativeLimit" />
                <xsl:with-param name="start" select="$start" />
                <xsl:with-param name="end" select="$end" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </table>
      </div>
      <div class="panel-footer clearfix">
        <span id="{$id}_info">
          <xsl:if test="$pages &gt; 1">
            <xsl:attribute name="class">hidden-xs</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="i18n:translate(concat($i18nprefix, '.filterInfo'), concat($start, ';', $end, ';', $total))" />
        </span>
        <xsl:if test="$pages &gt; 1">
          <xsl:call-template name="dataTablePaginate">
            <xsl:with-param name="id" select="$id" />
            <xsl:with-param name="i18nprefix" select="$i18nprefix" />
            <xsl:with-param name="pages" select="$pages" />
          </xsl:call-template>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="dataTableHeader">
    <thead>
      <tr>
        <xsl:for-each select="xalan:nodeset($headerCols)/col|xalan:nodeset($headerCols)/th">
          <xsl:variable name="sortOrderAfter">
            <xsl:choose>
              <xsl:when test="($SortBy = @sortBy) and ($SortOrder = 'asc')">
                <xsl:text>desc</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>asc</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="iconClass">
            <xsl:choose>
              <xsl:when test="($SortBy = @sortBy) and ($SortOrder = 'asc')">
                <xsl:text>glyphicon glyphicon-sort-by-attributes</xsl:text>
              </xsl:when>
              <xsl:when test="($SortBy = @sortBy) and ($SortOrder = 'desc')">
                <xsl:text>glyphicon glyphicon-sort-by-attributes-alt</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>glyphicon glyphicon-sort</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <th>
            <xsl:copy-of select="@*[not(contains('sortBy|sortOrder|sortType', name()))]" />
            <xsl:choose>
              <xsl:when test="string-length(@sortBy) &gt; 0">
                <a>
                  <xsl:attribute name="href">
                    <xsl:call-template name="dataTableQuerystring">
                      <xsl:with-param name="sortBy" select="@sortBy" />
                      <xsl:with-param name="sortOrder" select="$sortOrderAfter" />
                      <xsl:with-param name="sortType">
                        <xsl:choose>
                          <xsl:when test="@sortType">
                            <xsl:value-of select="@sortType" />
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>text</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:value-of select="text()" />
                  <span class="pull-left {$iconClass} sort-icon" />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="text()" />
              </xsl:otherwise>
            </xsl:choose>
          </th>
        </xsl:for-each>
      </tr>
    </thead>
  </xsl:template>

  <xsl:template name="dataTableBody">
    <xsl:param name="nativeLimit" select="false" />
    <xsl:param name="start" />
    <xsl:param name="end" />

    <xsl:variable name="sortedCol" select="$dataTableSortedCol" />

    <tbody>
      <xsl:variable name="sortOrder">
        <xsl:choose>
          <xsl:when test="$SortOrder = 'desc'">
            <xsl:text>descending</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>ascending</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:for-each select="./*">
        <xsl:sort
          select="*[name() = $SortBy]|@*[name() = $SortBy]|text()[$SortBy = 'text()']|descendant-or-self::*[name() = $SortBy]|descendant-or-self::*//@*[name() = $SortBy]"
          order="{$sortOrder}" data-type="{$SortType}" />

        <xsl:if test="((position() &gt;= $start) and (position() &lt;= $end)) or ($nativeLimit)">
          <xsl:variable name="trClass">
            <xsl:choose>
              <xsl:when test="position() mod 2 = 0">
                <xsl:text>even</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>odd</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="drow">
            <xsl:apply-templates mode="dataTableRow" select="." />
          </xsl:variable>

          <xsl:variable name="row">
            <xsl:choose>
              <xsl:when test="count(xalan:nodeset($drow)/row|xalan:nodeset($drow)/tr) &gt; 0">
                <xsl:copy-of select="$drow" />
              </xsl:when>
              <xsl:otherwise>
                <row>
                  <xsl:copy-of select="$drow" />
                </row>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:for-each select="xalan:nodeset($row)/row|xalan:nodeset($row)/tr">
            <tr class="{$trClass}">
              <!-- extra css class for row -->
              <xsl:if test="./class">
                <xsl:attribute name="class">
                  <xsl:value-of select="concat($trClass, ' ', ./class)" />
                </xsl:attribute>
              </xsl:if>
              <xsl:apply-templates select="@*" />
              <xsl:for-each select="./col|./td">
                <xsl:variable name="tdClass">
                  <xsl:if test="$sortedCol = position()">
                    <xsl:text>sorting_1</xsl:text>
                  </xsl:if>
                </xsl:variable>
                <td>
                  <xsl:if test="string-length($tdClass) &gt; 0">
                    <xsl:attribute name="class">
                    <xsl:value-of select="$tdClass" />
                  </xsl:attribute>
                  </xsl:if>
                  <xsl:apply-templates select="@*|node()" />
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
    </tbody>
  </xsl:template>

  <xsl:template name="dataTablePaginate">
    <xsl:param name="id" select="'dataTable'" />
    <xsl:param name="i18nprefix" select="'dataTable'" />
    <xsl:param name="pages" />

    <ul id="{$id}_paginate" class="pagination pagination-sm pull-right no-margin">
      <li>
        <xsl:choose>
          <xsl:when test="number($Page) &gt; 1">
            <a tabindex="0" id="{$id}_first">
              <xsl:attribute name="href">
                  <xsl:call-template name="dataTableQuerystring">
                    <xsl:with-param name="page" select="1" />
                  </xsl:call-template>
                </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;laquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.first'))" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;laquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.first'))" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
      <li>
        <xsl:choose>
          <xsl:when test="number($Page) &gt; 1">
            <a tabindex="0" id="{$id}_previous">
              <xsl:attribute name="href">
                  <xsl:call-template name="dataTableQuerystring">
                    <xsl:with-param name="page" select="$Page - 1" />
                  </xsl:call-template>
                </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;lsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.previous'))" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;lsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.previous'))" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>

      <!-- variable can be used to change numbers of Page entries to display -->
      <xsl:variable name="paginateMaxEntries" select="5" />
      <xsl:variable name="paginateBackCount" select="ceiling(($paginateMaxEntries - 1) div 2)" />
      <xsl:variable name="paginatePrevCount" select="$paginateMaxEntries - ceiling($paginateMaxEntries div 2)" />

      <xsl:variable name="paginateStart">
        <xsl:choose>
          <xsl:when test="((number($Page) - $paginateBackCount) &lt;= 1) or ($pages &lt; $paginateMaxEntries)">
            <xsl:value-of select="1" />
          </xsl:when>
          <xsl:when test="(number($Page) + $paginatePrevCount) &gt; $pages">
            <xsl:value-of select="number($Page) - $paginateBackCount - ((number($Page) + $paginatePrevCount) - $pages)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="number($Page) - $paginateBackCount" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="paginateEnd">
        <xsl:choose>
          <xsl:when test="((number($Page) + $paginatePrevCount) &gt;= $pages) or ($pages &lt; $paginateMaxEntries)">
            <xsl:value-of select="$pages" />
          </xsl:when>
          <xsl:when test="(number($Page) + $paginatePrevCount) &lt; $paginateMaxEntries">
            <xsl:value-of select="$paginateMaxEntries" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="number($Page) + $paginatePrevCount" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:call-template name="dataTablePaginateEntries">
        <xsl:with-param name="pages" select="$pages" />
        <xsl:with-param name="paginateStart" select="$paginateStart" />
        <xsl:with-param name="paginateEnd" select="$paginateEnd" />
      </xsl:call-template>

      <li>
        <xsl:choose>
          <xsl:when test="number($Page) &lt; $pages">
            <a tabindex="0" id="{$id}_next">
              <xsl:attribute name="href">
                  <xsl:call-template name="dataTableQuerystring">
                    <xsl:with-param name="page" select="$Page + 1" />
                  </xsl:call-template>
                </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;rsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.next'))" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;rsaquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.next'))" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
      <li>
        <xsl:choose>
          <xsl:when test="number($Page) &lt; $pages">
            <a tabindex="0" id="{$id}_last">
              <xsl:attribute name="href">
                <xsl:call-template name="dataTableQuerystring">
                  <xsl:with-param name="page" select="$pages" />
                </xsl:call-template>
              </xsl:attribute>
              <xsl:text disable-output-escaping="yes">&amp;raquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.last'))" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text disable-output-escaping="yes">&amp;raquo;</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="i18n:translate(concat($i18nprefix, '.last'))" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </ul>
  </xsl:template>

  <xsl:template name="dataTablePaginateEntries">
    <xsl:param name="pages" />
    <xsl:param name="paginateStart" />
    <xsl:param name="paginateEnd" />

    <xsl:if test="$paginateStart = number($Page)">
      <li class="active">
        <span>
          <xsl:value-of select="$paginateStart" />
        </span>
      </li>
    </xsl:if>
    <xsl:if test="$paginateStart != number($Page)">
      <li>
        <a tabindex="0">
          <xsl:attribute name="href">
            <xsl:call-template name="dataTableQuerystring">
              <xsl:with-param name="page" select="$paginateStart" />
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="$paginateStart" />
        </a>
      </li>
    </xsl:if>

    <xsl:if test="$paginateStart &lt; $paginateEnd">
      <xsl:call-template name="dataTablePaginateEntries">
        <xsl:with-param name="pages" select="$pages" />
        <xsl:with-param name="paginateStart" select="$paginateStart + 1" />
        <xsl:with-param name="paginateEnd" select="$paginateEnd" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Helper Variables/Functions -->

  <xsl:variable name="dataTableHeaderColCount">
    <xsl:value-of select="count(xalan:nodeset($headerCols)/col|xalan:nodeset($headerCols)/th)" />
  </xsl:variable>

  <xsl:variable name="dataTableSortedCol">
    <xsl:variable name="pos">
      <xsl:for-each select="xalan:nodeset($headerCols)/col|xalan:nodeset($headerCols)/th">
        <xsl:if test="$SortBy = @sortBy">
          <xsl:value-of select="position()" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$pos">
        <xsl:value-of select="$pos" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="dataTableQuerystring">
    <xsl:param name="sortBy" select="$SortBy" />
    <xsl:param name="sortOrder" select="$SortOrder" />
    <xsl:param name="sortType" select="$SortType" />
    <xsl:param name="perPage" select="$numPerPage" />
    <xsl:param name="page" select="$Page" />
    <xsl:param name="filter" select="$Filter" />

    <xsl:variable name="url1">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'SortBy'" />
        <xsl:with-param name="value" select="$sortBy" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="url2">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$url1" />
        <xsl:with-param name="par" select="'SortOrder'" />
        <xsl:with-param name="value" select="$sortOrder" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="url3">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$url2" />
        <xsl:with-param name="par" select="'SortType'" />
        <xsl:with-param name="value" select="$sortType" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="url4">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$url3" />
        <xsl:with-param name="par" select="'numPerPage'" />
        <xsl:with-param name="value" select="$perPage" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="url5">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$url4" />
        <xsl:with-param name="par" select="'Page'" />
        <xsl:with-param name="value" select="$page" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="url6">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$url5" />
        <xsl:with-param name="par" select="'Filter'" />
        <xsl:with-param name="value" select="$filter" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="$url6" />
  </xsl:template>

  <xsl:template name="dataTableFormValues">
    <xsl:param name="sortBy" select="$SortBy" />
    <xsl:param name="sortOrder" select="$SortOrder" />
    <xsl:param name="sortType" select="$SortType" />
    <xsl:param name="page" select="1" />

    <xsl:variable name="queryString">
      <xsl:choose>
        <xsl:when test="contains($RequestURL,'?')">
          <xsl:value-of select="substring-after($RequestURL,'?')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$RequestURL" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="params">
      <xsl:call-template name="str:tokenize">
        <xsl:with-param name="string" select="$queryString" />
        <xsl:with-param name="delimiters" select="'&amp;'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="xalan:nodeset($params)/token">
      <xsl:variable name="name" select="substring-before(., '=')" />
      <xsl:variable name="value" select="substring-after(., '=')" />

      <xsl:if test="not(contains('SortBy|SortOrder|SortType|Page|Filter|numPerPage', $name))">
        <input type="hidden" name="{$name}" value="{$value}" />
      </xsl:if>
    </xsl:for-each>

    <input type="hidden" name="SortBy" value="{$sortBy}" />
    <input type="hidden" name="SortOrder" value="{$sortOrder}" />
    <input type="hidden" name="SortType" value="{$sortType}" />
    <input type="hidden" name="Page" value="{$page}" />
  </xsl:template>

  <xsl:template match='@*|node()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>