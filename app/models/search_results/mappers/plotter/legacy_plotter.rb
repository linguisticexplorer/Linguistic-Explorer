module SearchResults

  module Mappers

    module Plotter
      class LegacyPlotter

        def initialize(data)
          @filename_path = calculate_path_from data
          @hamming_matrix = extract_hamming_matrix_from data
        end

        def path_to_img
          "/similarity_tree_images/#{@filename.to_s}"
        end

        def plot_it!
          # This will use cache file if there is one
          if !FileTest.exist? @filename_path

            require "rinruby"

            ### setting up R
            R.echo(false)

            ### Copy data to R
            copy_data_to_R_environment

            ### clustering
            clustering_data

            ### Plot dendrogram to PNG file
            plot_dendrogram
          end
        end


        private
        def plot_dendrogram
          filename_string_by_hash_code = "filename = '#{@filename_path.to_s}'"
          R.eval "png(#{filename_string_by_hash_code.to_s}, width=1100, height=650)"
          R.eval "plot(cluster, xlab = '')"
          # Close the current device
          R.eval "dev.off()"
        end

        def clustering_data
          R.eval "cluster = hclust(dist(hamming_matrix, 'manhattan'))"
        end

        def copy_data_to_R_environment
          R.keys = @hamming_matrix.keys
          R.hamming_matrix = convert_hash_to_matrix
          R.eval "rownames(hamming_matrix) <- keys"
        end

        def convert_hash_to_matrix
          rows_number = @hamming_matrix.size
          cols_number = @hamming_matrix.values.first.size

          # rinruby has problems with assign matrix too big
          raise Exceptions::ResultTooManyForLegacyClustering if rows_number * cols_number > 1600

          Matrix.build(rows_number, cols_number) { |row, col| @hamming_matrix.values[row][col] }
        end

        def extract_hamming_matrix_from(data)
          data.reject { |k, v| k.is_a? Symbol }
        end

        def calculate_filename(data)
          @filename ||="tree_#{data.hash.to_s}.png"
        end

        def calculate_path_from(data)
          Rails.root.join("public", "similarity_tree_images", calculate_filename(data))
        end

      end
    end
  end
end
