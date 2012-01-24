module SearchResults

  module Mappers

    module Plotter

      class D3jsPlotter

        def path_to_img
          @clustered_data.to_s
        end

        def plot_it!
          ### clustering
          @clustered_data ||= clustering_data
        end

        def extract_hamming_matrix_from(data)
          data.reject { |k, v| /prop_ids/.match(k.to_s) }
        end

        def initialize(data)
          @prop_ids = data[:prop_ids]
          @hamming_matrix = extract_hamming_matrix_from data
        end

        private

        def clustering_data
          HierarchicalClustering.new(@hamming_matrix, :newick).cluster(:manhattan)
        end

      end
    end
  end
end
